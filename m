From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: introduce simple actions
Date: Sun, 20 Mar 2005 21:18:36 +0100
Message-ID: <20050320201836.GW3086@postel.suug.ch>
References: <1111345551.1095.82.camel@jzny.localdomain> <20050320194408.GU3086@postel.suug.ch> <1111349426.1092.128.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Patrick McHardy <kaber@trash.net>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111349426.1092.128.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > > +
> > > +struct tc_defact
> > > +{
> > > +	tc_gen;
> > > +};
> > 
> > tcf_defact, tc_defact, .. quite easy to get this wrong. Maybe
> > it would a good idea to rename tcf_defact to tcf_defact_parm?
> > 
> 
> sigh. another LinuxWay(tm). Unfortunately this is all over the net/sched
> code to imply something thats user specific vs kernel specific. If
> you feel strongly about it i will change it - otherwise maybe we can
> leave it till some day some brave person will clean up the whole thing?

Yes I know and I don't feel that strong about it. I just tend to dislike
it a tiny bit, I do like the struct rta_kern style better. Let's wait for
the brave knight to appear someday.
