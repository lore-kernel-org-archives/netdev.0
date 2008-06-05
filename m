From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [2.6 patch] include/linux/ssb/ssb_driver_gige.h typo fix
Date: Thu, 5 Jun 2008 20:42:43 +0200
Message-ID: <200806052042.43670.mb@bu3sch.de>
References: <20080605182945.GO1469@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Robert P. J. Day" <rpjday@crashcourse.ca>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:34558 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753489AbYFESnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 14:43:21 -0400
In-Reply-To: <20080605182945.GO1469@cs181133002.pp.htv.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 05 June 2008 20:29:49 Adrian Bunk wrote:
> This patch fixes a typo in the name of a config variable.

Well, it's not a typo. It was renamed. Good catch anyway. :)

> Reported-by: Robert P. J. Day <rpjday@crashcourse.ca>
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Reviewed-by: Michael Buesch <mb@bu3sch.de>

> ---
> 2aab8eeb46b30baf987c344e1b144caec365373a diff --git a/include/linux/ssb/ssb_driver_gige.h b/include/linux/ssb/ssb_driver_gige.h
> index 01fbdf5..942e387 100644
> --- a/include/linux/ssb/ssb_driver_gige.h
> +++ b/include/linux/ssb/ssb_driver_gige.h
> @@ -100,7 +100,7 @@ extern char * nvram_get(const char *name);
>  /* Get the device MAC address */
>  static inline void ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
>  {
> -#ifdef CONFIG_BCM947XX
> +#ifdef CONFIG_BCM47XX
>  	char *res = nvram_get("et0macaddr");
>  	if (res)
>  		memcpy(macaddr, res, 6);
> 
> 
> 



-- 
Greetings Michael.
