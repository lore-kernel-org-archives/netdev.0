From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: using the hso driver with cisco vpn client
Date: Thu, 09 Oct 2008 11:36:01 -0400
Message-ID: <1223566561.18104.16.camel@dhcp-100-3-195.bos.redhat.com>
References: <48EE098F.8040407@option.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?N=E9meth_Tam=E1s?= <nice-OZwXound/Z2+mM1/5BeW/g@public.gmane.org>,
	Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Cisco Technical Support <tac-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Paul Hardwick <P.Hardwick-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48EE098F.8040407-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-10-09 at 15:39 +0200, Denis Joseph Barrow wrote:
> Hi Tamas,
> I just realised something. You don't need a faked ethernet port in the hso driver to get ciscos vpn
> client to work, I found out in the last few days that the modem port works
> just fine on the hso driver despite the misleading comment which implies otherwise.
> You should be able to use the modem interface in the hso driver to make a ppp connection,
> this should work with your vpn cisco client

But using this port is pointless, because it'll slow the connection
down.  What's the actual problem with using the netdevice?  Did I miss
something in the archives?

vpnc seems to work just fine in the normal 'hso' configuration with the
tty being the control port and the netdevice being the data port.

What encapsulation or NAT traversal method are you using?  Does 'vpnc'
work for you?  Are you using the cisco binary kernel module?

Dan

> I've included a sample wvdial script which I use to make my connection.
> You can use to ./ports.sh script from our 1.6 distribution on pharscape to find
> the modem port of the 3g modem
> 
> plain text document attachment (wvdial.conf)
> [Dialer Defaults]
> Modem = /dev/ttyHS4
> Stupid Mode = 1
> Init = AT+CGDCONT=1,,"internet.proximus.be"
> Dial = ATD
> Phone = *99#
> Username = vodaphone
> Password = vodaphone
> Carrier Check = 1 
> #New PPPD = yes

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
