From: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
Subject: Re: [PATCH 1/3] 6lowpan: add helper to get
	6lowpan namespace
Date: Tue, 22 Apr 2014 12:09:09 -0700
Message-ID: <CAB=NE6UW23sjr0kNMtDLashm-=N6+Pekiw58rSdt5UcJXhG=5w@mail.gmail.com>
References: <1397784176-15809-1-git-send-email-mcgrof@do-not-panic.com>
	<1397784176-15809-2-git-send-email-mcgrof@do-not-panic.com>
	<1398159886.4211.1.camel@jlt4.sipsolutions.net>
	<20140422095300.GA9241@omega>
	<20140422175818.GN27882@wotan.suse.de>
	<1398192315.4211.25.camel@jlt4.sipsolutions.net>
	<20140422184908.GA16477@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20140422184908.GA16477@omega>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 22, 2014 at 11:49 AM, Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Apr 22, 2014 at 08:45:15PM +0200, Johannes Berg wrote:
>> On Tue, 2014-04-22 at 19:58 +0200, Luis R. Rodriguez wrote:
>>
>> > > > > +#if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
>> > > > > [...]
>> > > > > +#else
>> > > > > +static inline struct netns_ieee802154_lowpan *
>> > > > > +net_ieee802154_lowpan(struct net *net)
>> > > > > +{
>> > > > > +     return NULL;
>> > > > > +}
>> > > > > +#endif
>> > > >
>> > > > Why would that be needed? If nobody compiles 802.15.4 then it seems
>> > > > nothing should reference it?
>> > > >
>> > > Indeed I think this is unnecessary, also.
>> >
>> > I wanted to be sure, and I was not. Right now 6lowpan does not depend
>> > on CONFIG_NET_NS, is this intentional? I think its fine without it
>> > but I was not sure.
>>
>> I fail to see how !CONFIG_LOWPAN is related CONFIG_NET_NS?
>>
>
> mhh, IEEE802154_6LOWPAN depends on IPV6 and I think IPV6 is related to
> CONFIG_NET_NS.

Just test compiled IEEE802154_6LOWPAN without NET_NS and then also
disabled IPV6 and it compiles, IEEE802154_6LOWPAN already depends on
IPV6.

  Luis

------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
