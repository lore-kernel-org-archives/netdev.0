From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] in6: fix conflict with glibc
Date: Mon, 22 Dec 2014 16:13:04 -0500 (EST)
Message-ID: <20141222.161304.335677296258096079.davem@davemloft.net>
References: <20141220121549.7c1b8aad@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, florent.fourcot-Pj3lBMu8rt9bbU8NOSLlsg@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141220121549.7c1b8aad@urahara>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Date: Sat, 20 Dec 2014 12:15:49 -0800

> Resolve conflicts between glibc definition of IPV6 socket options
> and those defined in Linux headers. Looks like earlier efforts to
> solve this did not cover all the definitions.
> 
> It resolves warnings during iproute2 build. 
> Please consider for stable as well.
> 
> Signed-off-by: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
> 
> ---
> Patch against -net tree

Applied and queued up for -stable, thanks Stephen.
