From: "David S. Miller" <davem@redhat.com>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Mon, 15 Sep 2003 15:59:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915155903.12a3f95d.davem@redhat.com>
References: <200309022116.41697.bdschuym@pandora.be>
	<20030905153152.GA3623@obroa-skai.de.gnumonks.org>
	<20030908191400.5ef59ab6.davem@redhat.com>
	<200309132159.37834.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, acme@conectiva.com.br,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200309132159.37834.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 13 Sep 2003 21:59:37 +0200
Bart De Schuymer <bdschuym@pandora.be> wrote:

> -	char physindev[IFNAMSIZ];
> +	char physindev[IFNAMSIZ] __attribute__ ((aligned (__alignof__(unsigned int))));

I have to reject the fix for this problem again.

You can't change the struct exported to userspace in any way
without breaking the tools.  I tried to explain this in the
first revision of your change.
