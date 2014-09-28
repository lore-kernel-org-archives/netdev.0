From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2] add help command to bonding master
Date: Sun, 28 Sep 2014 16:07:40 -0700
Message-ID: <20140928160740.5e90ba9f@urahara>
References: <1409923456-14596-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nikolay@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:62126 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbaI1XHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 19:07:52 -0400
Received: by mail-pd0-f170.google.com with SMTP id ft15so401528pdb.29
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 16:07:51 -0700 (PDT)
In-Reply-To: <1409923456-14596-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  5 Sep 2014 15:24:16 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  ip/iplink_bond.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
> index b5c511e..0a1ed03 100644
> --- a/ip/iplink_bond.c
> +++ b/ip/iplink_bond.c
> @@ -339,6 +339,9 @@ static int bond_parse_opt(struct link_util *lu, int argc, char **argv,
>  			}
>  			ad_select = get_index(ad_select_tbl, *argv);
>  			addattr8(n, 1024, IFLA_BOND_AD_SELECT, ad_select);
> +		} else if (matches(*argv, "help") == 0) {
> +			explain();
> +			return -1;
>  		} else {
>  			fprintf(stderr, "bond: unknown command \"%s\"?\n", *argv);
>  			explain();

Applied
