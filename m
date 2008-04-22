From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Tue, 22 Apr 2008 10:52:49 +0200
Message-ID: <200804221052.50023.oliver@neukum.org>
References: <20080417214719.GF17664@kroah.com> <20080421184157.106603602C8@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <480D0F5B.9010808@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <480D0F5B.9010808-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 22. April 2008 00:04:11 schrieb Paulius Zaleckas:
> I would agree with you, but... To make this interface work you have to
> send AT command with APN and optionally with PAP/CHAP username and password.
> Then you call AT command witch initiates PPP with basestation and begins
> to send/receive traffic on this pseudo ethernet interface... Actually it
> still needs one more AT command to get your IP and DNS addresses.
> Then you do: ifconfig hso0 xxx.xxx.xxx.xxx netmask 255.255.255.255 up
> And then you have to write DNS addresses (got through AT interface) to
> the /etc/resolv.conf. Now you have a working internet connection!
> 
> So... I don't see any chance to do multicasting or broadcasting here...
> IMO the only way to distribute this kind of connection to local network
> is to do NAT'ing :( Am I wrong?

But what in this setup would prevent the other end of the connection
from sending packets to a multicast address down the link? If that
can happen, the questions remains, can the device filter these packets
in hardware?

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
