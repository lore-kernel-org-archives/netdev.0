From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 7/6] cls_fw: CONFIG_NET_CLS_IND is not dependant on CONFIG_NET_CLS_ACT
Date: Fri, 29 Oct 2004 13:53:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029115333.GK12289@postel.suug.ch>
References: <20041029002113.GY12289@postel.suug.ch> <20041029102620.GH12289@postel.suug.ch> <1099049980.1024.21.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1099049980.1024.21.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1099049980.1024.21.camel@jzny.localdomain> 2004-10-29 07:39
> Thomas, Can you submit equivalent patches for cls_u32.c?

Sure, already done and queued for submission. I will submit them today.

> Thomas, I will let Dave suck these in first and test against resulting
> bk.

OK.

Regarding the generic statistics for actions:

I thought about dumping the most common stats basic,queue,rate_est
in tcf_action_copy_stats and let the action module dump additional
stats in its get_stats implementation. Any objections in creating
struct tca_act_gen with the content of tca_gen and use it to
access a->priv from act_api.c to get my hands on the statistics
and stats_lock?
