From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2.6] SoftMAC : fix duplicate display of channel in scan
Date: Thu, 12 Jul 2007 09:34:40 -0700
Message-ID: <20070712163440.GA13445@bougret.hpl.hp.com>
References: <20070710184155.GA6955@bougret.hpl.hp.com> <4693DD18.1010905@lwfinger.net> <1184211018.9446.0.camel@localhost.localdomain>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1184211018.9446.0.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 11, 2007 at 11:30:17PM -0400, Dan Williams wrote:
> On Tue, 2007-07-10 at 14:25 -0500, Larry Finger wrote:
> > Jean,
> > 
> > Jean Tourrilhes wrote:
> > > 	Hi,
> > > 
> > > 	SoftMAC output the channel twice in the scan output. It should
> > > display frequency and channel, but only once for each.
> > > --------------------------------------------------------
> > >           Cell 02 - Address: A2:00:04:XX:XX:XX
> > >                     ESSID:"TheESSID"
> > >                     Protocol:IEEE 802.11b
> > >                     Mode:Ad-Hoc
> > > ->                  Channel:5
> > > ->                  Frequency:2.432 GHz (Channel 5)
> > 
> > The frequency output is needed by NetworkManager, which is why I added it. At that time, I thought 
> > that some tool or other might be scanning the output looking for "Channel:", not "Channel "; 
> > therefore I left both in. If we are sure that removing the channel-only line will not break 
> > something, I'll be happy to send your patch upstream.
> 
> Should fix NM, really, to deal with either channel or frequency and
> handle each as appropriate.
> 
> Dan

	Well, I actually like forcing driver to use frequency, because
that's an absolute physical measure and contains more meaning.
	Regards,

	Jean
