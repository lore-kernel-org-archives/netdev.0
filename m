From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Tue, 11 Jan 2005 00:30:47 +0100
Message-ID: <20050110233047.GC26856@postel.suug.ch>
References: <20050105110048.GO26856@postel.suug.ch> <1104931991.1117.152.camel@jzny.localdomain> <20050105144514.GQ26856@postel.suug.ch> <1105019225.2312.7.camel@jzny.localdomain> <20050106194102.GW26856@postel.suug.ch> <1105105511.1046.77.camel@jzny.localdomain> <20050108145457.GZ26856@postel.suug.ch> <1105363582.1041.162.camel@jzny.localdomain> <20050110211747.GA26856@postel.suug.ch> <1105394738.1085.63.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105394738.1085.63.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1105394738.1085.63.camel@jzny.localdomain> 2005-01-10 17:05
> On Mon, 2005-01-10 at 16:17, Thomas Graf wrote:
> > * jamal <1105363582.1041.162.camel@jzny.localdomain> 2005-01-10 08:26
> > > I think its _a hack_ Thomas ;-> Mostly because it has dependency on u32.
> > > off2 doesnt exist on any other classifier and the basic ematch should be
> > > usable by any classifier.
> > 
> > It does not, u32 does have a dependency on em_u32 but not vice versa.
> > em_u32 is perfectly useful even without nexthdr functionality since
> > this is the way it is used today in 90% of the cases and it should be
> > a little bit faster than em_cmp but also a bit less powerful. On top
> > of that, rsvp could provide this information as well so one could
> > extend rsvp with em_u32 ematches. I think we should not think of it
> > as being dependant on off2 but rather as it is able to use information
> > from a underlying layer.
> 
> Ok, you make a convincing arguement ;-> No more concerns from my side.
> Churn that code!

I started testing via the basic classifier but will do the cls_u32
changes soon and then remerge and do the final tests once all the
other pkt_sched changes have made it into linus's tree and I can
work from a fresh bk tree. I'll also try to find the time this week
to do the iproute2 changes for the tcf_exts changset so iproute2 is
actually capable of configuring actions for all classifiers.
