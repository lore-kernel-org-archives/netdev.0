From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/9] PKT_SCHED: u32: make use of tcf_exts API
Date: 30 Dec 2004 23:43:21 -0500
Message-ID: <1104468201.1047.201.camel@jzny.localdomain>
References: <20041230122652.GM32419@postel.suug.ch>
	 <20041230123108.GP32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041230123108.GP32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-12-30 at 07:31, Thomas Graf wrote:

>  
> +static struct tcf_ext_map u32_ext_map = {
> +	.action = TCA_U32_ACT,
> +	.police = TCA_U32_POLICE
> +};

Repeated on all classifiers - perhaps a little macro magic in order? ;->

Generally rest all looking good - I need to stare some more at the route
and tcindex one but dont see any show stoppers off hand;

cheers,
jamal
