From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2-next 1/2] include: update linux/rtnetlink.h
Date: Fri, 10 Apr 2015 13:24:21 -0700
Message-ID: <20150410132421.599eaf5e@urahara>
References: <1428568214-8673-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34752 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754854AbbDJUYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 16:24:25 -0400
Received: by pdbqa5 with SMTP id qa5so33131111pdb.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 13:24:24 -0700 (PDT)
In-Reply-To: <1428568214-8673-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Apr 2015 10:30:13 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  include/linux/rtnetlink.h | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index 28650a31d77f..702b19b4207e 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -134,6 +134,8 @@ enum {
>  
>  	RTM_NEWNSID = 88,
>  #define RTM_NEWNSID RTM_NEWNSID
> +	RTM_DELNSID = 89,
> +#define RTM_DELNSID RTM_DELNSID
>  	RTM_GETNSID = 90,
>  #define RTM_GETNSID RTM_GETNSID
>  
> @@ -633,6 +635,8 @@ enum rtnetlink_groups {
>  #define RTNLGRP_MDB		RTNLGRP_MDB
>  	RTNLGRP_MPLS_ROUTE,
>  #define RTNLGRP_MPLS_ROUTE	RTNLGRP_MPLS_ROUTE
> +	RTNLGRP_NSID,
> +#define RTNLGRP_NSID		RTNLGRP_NSID
>  	__RTNLGRP_MAX
>  };
>  #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)

Unnecessary, already don on net-next branch
