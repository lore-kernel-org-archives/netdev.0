From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/9] PKT_SCHED: u32: make use of tcf_exts API
Date: Fri, 31 Dec 2004 13:03:44 +0100
Message-ID: <20041231120344.GH32419@postel.suug.ch>
References: <20041230122652.GM32419@postel.suug.ch> <20041230123108.GP32419@postel.suug.ch> <1104468201.1047.201.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104468201.1047.201.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104468201.1047.201.camel@jzny.localdomain> 2004-12-30 23:43
> On Thu, 2004-12-30 at 07:31, Thomas Graf wrote:
> 
> >  
> > +static struct tcf_ext_map u32_ext_map = {
> > +	.action = TCA_U32_ACT,
> > +	.police = TCA_U32_POLICE
> > +};
> 
> Repeated on all classifiers - perhaps a little macro magic in order? ;->

I thought about this but couldn't come up with one that makes it
actually easier. I don't want to hardcode action/police in a macro
because we might have extensions only needed for specific classifiers.

> Generally rest all looking good - I need to stare some more at the route
> and tcindex one but dont see any show stoppers off hand;

Yes please, those are the critical points.
