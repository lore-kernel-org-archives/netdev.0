From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2 1/1] man page: add page for skbmod action
Date: Fri, 17 Feb 2017 09:00:51 +0100
Message-ID: <20170217080049.GA16596@penelope.horms.nl>
References: <1486769334-5534-1-git-send-email-lucasb@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, jhs@mojatatu.com, mrv@mojatatu.com,
        netdev@vger.kernel.org
To: Lucas Bates <lucasb@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:35698 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754838AbdBQIAz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 03:00:55 -0500
Received: by mail-wr0-f178.google.com with SMTP id c4so25246860wrd.2
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 00:00:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1486769334-5534-1-git-send-email-lucasb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 06:28:54PM -0500, Lucas Bates wrote:
> Signed-off-by: Lucas Bates <lucasb@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> ---
>  man/man8/Makefile    |   2 +-
>  man/man8/tc-skbmod.8 | 137 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 138 insertions(+), 1 deletion(-)
>  create mode 100644 man/man8/tc-skbmod.8
> 
> diff --git a/man/man8/Makefile b/man/man8/Makefile
> index bc2fc81..1bd2f02 100644
> --- a/man/man8/Makefile
> +++ b/man/man8/Makefile
> @@ -16,7 +16,7 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
>  	tc-basic.8 tc-cgroup.8 tc-flow.8 tc-flower.8 tc-fw.8 tc-route.8 \
>  	tc-tcindex.8 tc-u32.8 tc-matchall.8 \
>  	tc-connmark.8 tc-csum.8 tc-mirred.8 tc-nat.8 tc-pedit.8 tc-police.8 \
> -	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8  tc-ife.8 \
> +	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8 tc-skbmod.8 tc-ife.8 \
>  	tc-tunnel_key.8 \
>  	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8 \
>  	ifstat.8

FWIW the above does not seem to apply cleanly against the net-next branch.

The above not withstanding I am very pleased to see this documentation
and in particular the presence of examples in it.

Reviewed-by: Simon Horman <simon.horman@netronome.com>


Do you know if there are any plans to extend the number of fields supported
by skmod? I think it would be useful to use it to allow matches to be
robust in the presence of variable length options: e.g. to modify L4 ports
fields in the presence (or absence) of IP options.
