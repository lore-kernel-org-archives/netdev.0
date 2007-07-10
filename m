From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2.6] SoftMAC : fix duplicate display of channel in scan
Date: Tue, 10 Jul 2007 12:47:17 -0700
Message-ID: <20070710194717.GA7310@bougret.hpl.hp.com>
References: <20070710184155.GA6955@bougret.hpl.hp.com> <4693DD18.1010905@lwfinger.net>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4693DD18.1010905-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 10, 2007 at 02:25:12PM -0500, Larry Finger wrote:
> Jean,
> 
> Jean Tourrilhes wrote:
> >	Hi,
> >
> >	SoftMAC output the channel twice in the scan output. It should
> >display frequency and channel, but only once for each.
> >--------------------------------------------------------
> >          Cell 02 - Address: A2:00:04:XX:XX:XX
> >                    ESSID:"TheESSID"
> >                    Protocol:IEEE 802.11b
> >                    Mode:Ad-Hoc
> >->                  Channel:5
> >->                  Frequency:2.432 GHz (Channel 5)
> 
> The frequency output is needed by NetworkManager, which is why I added it. 
> At that time, I thought that some tool or other might be scanning the 
> output looking for "Channel:", not "Channel "; therefore I left both in.

	All of the other drivers display only a single line, and
SoftMAC is the odd one here. I think that have the info twice may
confuse some tools.
	I know that there are scripts that parse iwlist output,
however I'm not keen on the practice, as there are alternatives.

> If we are sure that removing the channel-only line will not break
> something, I'll be happy to send your patch upstream.

	Unfortunately, I can't guarantee that. I can only guarantee
that it will be similar to what other drivers do.

> Larry

	Have fun...

	Jean
