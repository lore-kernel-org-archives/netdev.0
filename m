From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2.6] SoftMAC : fix duplicate display of channel in scan
Date: Wed, 11 Jul 2007 23:30:17 -0400
Message-ID: <1184211018.9446.0.camel@localhost.localdomain>
References: <20070710184155.GA6955@bougret.hpl.hp.com>
	 <4693DD18.1010905@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4693DD18.1010905-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-10 at 14:25 -0500, Larry Finger wrote:
> Jean,
> 
> Jean Tourrilhes wrote:
> > 	Hi,
> > 
> > 	SoftMAC output the channel twice in the scan output. It should
> > display frequency and channel, but only once for each.
> > --------------------------------------------------------
> >           Cell 02 - Address: A2:00:04:XX:XX:XX
> >                     ESSID:"TheESSID"
> >                     Protocol:IEEE 802.11b
> >                     Mode:Ad-Hoc
> > ->                  Channel:5
> > ->                  Frequency:2.432 GHz (Channel 5)
> 
> The frequency output is needed by NetworkManager, which is why I added it. At that time, I thought 
> that some tool or other might be scanning the output looking for "Channel:", not "Channel "; 
> therefore I left both in. If we are sure that removing the channel-only line will not break 
> something, I'll be happy to send your patch upstream.

Should fix NM, really, to deal with either channel or frequency and
handle each as appropriate.

Dan

> Larry
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
