From: Joe Perches <joe@perches.com>
Subject: Re: [patch net-next 16/19] lib: Introduce priority array area
 manager
Date: Thu, 02 Feb 2017 14:51:10 -0800
Message-ID: <1486075870.22276.43.camel@perches.com>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
         <1486048379-19237-17-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0018.hostedemail.com ([216.40.44.18]:51861 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751726AbdBBWvS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 17:51:18 -0500
In-Reply-To: <1486048379-19237-17-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-02 at 16:12 +0100, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> This introduces a infrastructure for management of linear priority
> areas. Priority order in an array matters, however order of items inside
> a priority group does not matter.
> 
> As an initial implementation, L-sort algorithm is used. It is quite
> trivial. More advanced algorithm called P-sort will be introduced as a
> follow-up. The infrastructure is prepared for other algos.
> 
> Alongside this, a testing module is introduced as well.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  MAINTAINERS            |   8 +
>  include/linux/parman.h |  76 ++++++++++
[]
> diff --git a/MAINTAINERS b/MAINTAINERS
[]
> @@ -9375,6 +9375,14 @@ F:	drivers/video/fbdev/sti*
>  F:	drivers/video/console/sti*
>  F:	drivers/video/logo/logo_parisc*
>  
> +PARMAN

This is not particularly descriptive.
Perhaps expand the section header a little like:

PARMAN - Linear priority array areas manager

> diff --git a/include/linux/parman.h b/include/linux/parman.h
[]
> @@ -0,0 +1,76 @@
> +/*
> + * include/linux/parman.h - Manager for linear priority array areas
[]
> diff --git a/lib/Kconfig b/lib/Kconfig
[]
> @@ -550,4 +550,7 @@ config STACKDEPOT
>  config SBITMAP
>  	bool
>  
> +config PARMAN
> +	tristate "parman"

help section?  Why should this be selected?
