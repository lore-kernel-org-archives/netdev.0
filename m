From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 4/5] ehea: fix phyp checkpatch complaints
Date: Fri, 1 Feb 2008 13:23:45 -0600
Message-ID: <20080201192344.GA4541@loki.buserror.net>
References: <1201832451-23634-1-git-send-email-dwm@austin.ibm.com> <1201832451-23634-5-git-send-email-dwm@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@garzik.org>,
	Linux PowerPC List <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	Jan-Bernd Themann <themann@de.ibm.com>
To: Doug Maxey <dwm@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:35814 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923AbYBATYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 14:24:47 -0500
Content-Disposition: inline
In-Reply-To: <1201832451-23634-5-git-send-email-dwm@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2008 at 08:20:50PM -0600, Doug Maxey wrote:
>  /* input param R5 */
> -#define H_ALL_RES_QP_EQPO         EHEA_BMASK_IBM(9, 11)
> -#define H_ALL_RES_QP_QPP          EHEA_BMASK_IBM(12, 12)
> -#define H_ALL_RES_QP_RQR          EHEA_BMASK_IBM(13, 15)
> -#define H_ALL_RES_QP_EQEG         EHEA_BMASK_IBM(16, 16)
> -#define H_ALL_RES_QP_LL_QP        EHEA_BMASK_IBM(17, 17)
> -#define H_ALL_RES_QP_DMA128       EHEA_BMASK_IBM(19, 19)
> -#define H_ALL_RES_QP_HSM          EHEA_BMASK_IBM(20, 21)
> -#define H_ALL_RES_QP_SIGT         EHEA_BMASK_IBM(22, 23)
> -#define H_ALL_RES_QP_TENURE       EHEA_BMASK_IBM(48, 55)
> -#define H_ALL_RES_QP_RES_TYP      EHEA_BMASK_IBM(56, 63)
> +#define H_ALL_RES_QP_EQPO	  EHEA_BMASK_IBM(9, 11)
> +#define H_ALL_RES_QP_QPP	  EHEA_BMASK_IBM(12, 12)
> +#define H_ALL_RES_QP_RQR	  EHEA_BMASK_IBM(13, 15)
> +#define H_ALL_RES_QP_EQEG	  EHEA_BMASK_IBM(16, 16)
> +#define H_ALL_RES_QP_LL_QP	  EHEA_BMASK_IBM(17, 17)
> +#define H_ALL_RES_QP_DMA128	  EHEA_BMASK_IBM(19, 19)
> +#define H_ALL_RES_QP_HSM	  EHEA_BMASK_IBM(20, 21)
> +#define H_ALL_RES_QP_SIGT	  EHEA_BMASK_IBM(22, 23)
> +#define H_ALL_RES_QP_TENURE	  EHEA_BMASK_IBM(48, 55)
> +#define H_ALL_RES_QP_RES_TYP	  EHEA_BMASK_IBM(56, 63)

This was better the way it was (before, it was readable at any tab setting);
checkpatch is overeager to complain on tab/space issues (it's a bit hard to
distinguish indentation from alignment with a regex).

-Scott
