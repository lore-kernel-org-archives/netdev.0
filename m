From: jamal <hadi@cyberus.ca>
Subject: Re: ing_filter debug messages
Date: 31 Dec 2004 00:07:46 -0500
Message-ID: <1104469666.1049.231.camel@jzny.localdomain>
References: <20041230160643.GD24603@wiggy.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
In-Reply-To: <20041230160643.GD24603@wiggy.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The emssage is useful but debug (mostly). 
Whats your ifconfig look like? Have some tunnels in there maybe?
Whats your netfilter setup? 

cheers,
jamal

On Thu, 2004-12-30 at 11:06, Wichert Akkerman wrote:
> After upgrading a machine to (unpatched mainline) 2.6.10 my kernel log
> is filled with ing_filter (debug?) messages:
> 
> Dec 30 16:24:58 thunder kernel: ing_filter:  fixed  eth1 out eth1
> Dec 30 16:24:58 thunder kernel: ing_filter:  fixed  eth1 out eth1
> Dec 30 16:37:08 thunder kernel: ing_filter:  fixed  eth1 out eth1
> Dec 30 16:37:08 thunder kernel: ing_filter:  fixed  eth1 out eth1
> Dec 30 16:49:08 thunder kernel: ing_filter:  fixed  eth1 out eth1
> Dec 30 16:49:08 thunder kernel: ing_filter:  fixed  eth1 out eth1
> Dec 30 17:01:08 thunder kernel: ing_filter:  fixed  eth1 out eth1
> Dec 30 17:01:08 thunder kernel: ing_filter:  fixed  eth1 out eth1
> 
> the messages always come in pairs. eth1 is the externel interface which
> has a standard wondershaper configuration attached to it. Relevant bits
> of .config are below.
> 
> Wichert.
> 
> 
> #
> # QoS and/or fair queueing
> #
> CONFIG_NET_SCHED=y
> CONFIG_NET_SCH_CLK_JIFFIES=y
> # CONFIG_NET_SCH_CLK_GETTIMEOFDAY is not set
> # CONFIG_NET_SCH_CLK_CPU is not set
> CONFIG_NET_SCH_CBQ=y
> CONFIG_NET_SCH_HTB=y
> # CONFIG_NET_SCH_HFSC is not set
> # CONFIG_NET_SCH_PRIO is not set
> # CONFIG_NET_SCH_RED is not set
> CONFIG_NET_SCH_SFQ=y
> # CONFIG_NET_SCH_TEQL is not set
> CONFIG_NET_SCH_TBF=y
> # CONFIG_NET_SCH_GRED is not set
> # CONFIG_NET_SCH_DSMARK is not set
> # CONFIG_NET_SCH_NETEM is not set
> CONFIG_NET_SCH_INGRESS=y
> CONFIG_NET_QOS=y
> CONFIG_NET_ESTIMATOR=y
> CONFIG_NET_CLS=y
> CONFIG_NET_CLS_TCINDEX=y
> CONFIG_NET_CLS_ROUTE4=y
> CONFIG_NET_CLS_ROUTE=y
> CONFIG_NET_CLS_FW=y
> CONFIG_NET_CLS_U32=y
> # CONFIG_CLS_U32_PERF is not set
> # CONFIG_NET_CLS_IND is not set
> CONFIG_NET_CLS_RSVP=y
> CONFIG_NET_CLS_RSVP6=y
> CONFIG_NET_CLS_ACT=y
> CONFIG_NET_ACT_POLICE=y
> CONFIG_NET_ACT_GACT=y
> CONFIG_GACT_PROB=y
> CONFIG_NET_ACT_MIRRED=y
> CONFIG_NET_ACT_IPT=y
> CONFIG_NET_ACT_PEDIT=y
> 
