From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.0-test9 : bridge freezes
Date: Tue, 16 Dec 2003 13:49:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031216134957.242b1145.davem@redhat.com>
References: <Pine.LNX.4.44.0312160859290.16778-100000@sorbus2.navaho>
	<200312162246.45994.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: steve@navaho.co.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200312162246.45994.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Dec 2003 22:46:45 +0100
Bart De Schuymer <bdschuym@pandora.be> wrote:

>  #ifdef CONFIG_BRIDGE_NETFILTER
> +	nf_bridge_put(to->nf_bridge);
>  	to->nf_bridge = from->nf_bridge;
>  	nf_bridge_get(to->nf_bridge);
>  #endif

Now this change makes a LOT of sense, great that you discovered it.

Steve, we eagerly wait your test results :)
