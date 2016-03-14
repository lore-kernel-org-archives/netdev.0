From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH 1/2 net v3.16]r8169:  Not enable/disable bus mastering
 when is enabled on BIOS
Date: Mon, 14 Mar 2016 13:22:21 +0100
Message-ID: <20160314122220.GC12759@unicorn.suse.cz>
References: <1457861569-1844-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39273 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964816AbcCNMWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 08:22:22 -0400
Content-Disposition: inline
In-Reply-To: <1457861569-1844-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 13, 2016 at 11:32:48AM +0200, Corcodel Marian wrote:
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 02aec96..ec555e7 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -754,6 +754,7 @@ struct rtl8169_private {
>  	struct timer_list timer;
>  	u16 cp_cmd;
>  	bool pcie;
> +	bool bios_support;

You shouldn't base your patches on earlier patches that haven't been
accepted yet (unless they are part of the same series).

Michal Kubecek
