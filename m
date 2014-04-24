From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Linux-zigbee-devel] [PATCH] 6lowpan: nuke
 net_ieee802154_lowpan() accessor when 6lowpan is disabled
Date: Thu, 24 Apr 2014 19:33:35 +0200
Message-ID: <20140424173333.GA21799@omega>
References: <1398193438-23805-1-git-send-email-mcgrof@do-not-panic.com>
 <20140424164445.GA4675@omega>
 <CAB=NE6XS9-Zu9sb5geO2WTnnvv6KqyT+QnL5bRf1fiRx3=ocrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
Return-path: <backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAB=NE6XS9-Zu9sb5geO2WTnnvv6KqyT+QnL5bRf1fiRx3=ocrg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Luis,

On Thu, Apr 24, 2014 at 10:25:58AM -0700, Luis R. Rodriguez wrote:
> On Thu, Apr 24, 2014 at 9:44 AM, Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > Hi,
> >
> > On Tue, Apr 22, 2014 at 12:03:58PM -0700, Luis R. Rodriguez wrote:
> >> From: "Luis R. Rodriguez" <mcgrof-IBi9RG/b67k@public.gmane.org>
> >>
> >> Johannes noted this is not needed, all of the fragment
> >> accessors don't need CONFIG_NET_NS. This goes test compiled with
> >> CONFIG_BT_6LOWPAN=y and a disabled CONFIG_NET_NS.
> >>
> >
> > a little note about this here. There exists two 6LoWPAN standard. One
> > for bluetooth low energy and one for IEEE 802.15.4.
> >
> > The actual namespace is only for IEEE 802.15.4, because we need
> > fragmentation there. 6LoWPAN fragmentation for bluetooth low energy is
> > already handled by the MAC-Layer. So this has nothing to do with
> > CONFIG_BT_6LOWPAN.
> 
> Thanks for the clarification, I actually did mean
> CONFIG_IEEE802154_6LOWPAN however, I goofed that on the commit log.
> 

ok. But I need to say thanks for sending this patch! :-)

It's nice to see that the community helps to improving the code which I
produced and it's really not perfect at the moment. (I was a little bit
shocked that somebody makes the effort to making a backport about that).

- Alex
