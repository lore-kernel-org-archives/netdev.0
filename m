From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rtnetlink & address family problem
Date: Tue, 7 Dec 2004 15:10:33 +0100
Message-ID: <20041207141033.GD1371@postel.suug.ch>
References: <41B0A5B4.6060108@suse.cz> <20041206140214.GA749@postel.suug.ch> <1102386461.1093.26.camel@jzny.localdomain> <20041207124922.GA1371@postel.suug.ch> <1102424568.1089.120.camel@jzny.localdomain> <20041207131706.GB1371@postel.suug.ch> <1102425618.1089.133.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Ludvig <mludvig@suse.cz>, Andrew Morton <akpm@osdl.org>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Jan Kara <jack@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1102425618.1089.133.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1102425618.1089.133.camel@jzny.localdomain> 2004-12-07 08:20
> On Tue, 2004-12-07 at 08:17, Thomas Graf wrote:
> 
> > It's not really related to the gnet_stats code.  stats_lock isn't set
> > in the action code when using an older iproute2. I haven't tested this
> > case because it was marked as broken anyway. 
> 
> Can you ping my memory on this? Is this tc with initial support
> for actions or something much older than that.

I'm not sure, I'm testing with a version having no action support at
all. It should be fairly easy to find the bug once I have the time to
really look into it. I'm still getting interrupted all the time at
the moment.

All actions created via tcf_hash_create, tcf_police_locate, and
tcf_act_police_locate should be fine. There must be some bogus path
related to older tc versions.
