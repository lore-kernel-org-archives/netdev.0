From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 1/6] netfilter-ipv4: Line layout whitespace fixes
Date: Fri, 16 Oct 2015 19:22:26 +0200
Message-ID: <20151016172226.GB3346@salvia>
References: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
 <1444861028-21556-2-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444861028-21556-2-git-send-email-ipm@chirality.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 14, 2015 at 11:17:03PM +0100, Ian Morris wrote:
> Cleanses some whitespace issues by removing a leading space before a tab.
> 
> No changes detected by objdiff.
> 
> Signed-off-by: Ian Morris <ipm@chirality.org.uk>
> ---
>  net/ipv4/netfilter/ipt_ECN.c           | 2 +-
>  net/ipv4/netfilter/nf_nat_pptp.c       | 2 +-
>  net/ipv4/netfilter/nf_nat_snmp_basic.c | 2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
> index 2707652..6592708 100644
> --- a/net/ipv4/netfilter/ipt_ECN.c
> +++ b/net/ipv4/netfilter/ipt_ECN.c
> @@ -24,7 +24,7 @@ MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
>  MODULE_DESCRIPTION("Xtables: Explicit Congestion Notification (ECN) flag modification");
>  
>  /* set ECT codepoint from IP header.
> - * 	return false if there was an error. */
> + *	return false if there was an error. */

In netdev coding style we prefer for multiline comments:

/* This is a comment blah blah blah blah blah blah blah blah blah blah blah blah
 * blah blah blah.
 */

For single line:

/* This is a comment blah blah blah */

This case, I suggest we can even get rid of that comment there since
it's obvious what set_ect_ip() is doing by reading the function name
and looking at what it returns.
