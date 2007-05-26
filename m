From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 4/7] cxgb3 - Update FW to 4.1
Date: Sun, 27 May 2007 01:05:09 +0200
Message-ID: <200705270105.10188.mb@bu3sch.de>
References: <20070526230003.12156.10521.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:45044
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbXEZXFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 19:05:21 -0400
In-Reply-To: <20070526230003.12156.10521.stgit@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 27 May 2007 01:00:04 divy@chelsio.com wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Bump FW version to 4.1.
> Modify chip tuning in consequence.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---

> @@ -2496,11 +2500,11 @@ static void __devinit init_mtus(unsigned
>  	 * it can accomodate max size TCP/IP headers when SACK and timestamps
>  	 * are enabled and still have at least 8 bytes of payload.
>  	 */
> -	mtus[0] = 88;
> -	mtus[1] = 256;
> -	mtus[2] = 512;
> -	mtus[3] = 576;
> -	mtus[4] = 808;
> +	mtus[1] = 88;
> +	mtus[1] = 88;

looks like a typo.

> +	mtus[2] = 256;
> +	mtus[3] = 512;
> +	mtus[4] = 576;
>  	mtus[5] = 1024;
>  	mtus[6] = 1280;
>  	mtus[7] = 1492;

-- 
Greetings Michael.
