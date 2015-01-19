From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [net-next PATCH v2 03/12] net: flow: implement flow cache for
 get routines
Date: Mon, 19 Jan 2015 14:08:30 +0900
Message-ID: <20150119050828.GC5612@vergenet.net>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
 <20150113213621.13874.40461.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, sfeldma@gmail.com, netdev@vger.kernel.org,
	gerlitz.or@gmail.com, jhs@mojatatu.com, andy@greyhouse.net,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:58583 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbbASFIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 00:08:42 -0500
Received: by mail-pd0-f174.google.com with SMTP id ft15so5145796pdb.5
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 21:08:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150113213621.13874.40461.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2015 at 01:36:22PM -0800, John Fastabend wrote:

[snip]

> diff --git a/include/linux/if_flow.h b/include/linux/if_flow.h
> index 23dec9b..dc70e3e 100644
> --- a/include/linux/if_flow.h
> +++ b/include/linux/if_flow.h

[snip]

> @@ -198,10 +201,28 @@ struct net_flow_tbl_node {
>   * Flows must match all entries in match set.
>   */
>  struct net_flow_rule {
> +	struct rhash_head node;

Hi John,

its seems that the 'node' field is new to this structure,
as compared with earlier versions with of this code, and
that some documentation for it should be added to
the comment immediately above the struct definition?

[snip]
