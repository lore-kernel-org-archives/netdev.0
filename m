From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4 1/2] netdev: driver: ethernet: add cpsw address
 lookup engine support
Date: Tue, 28 Feb 2012 20:48:53 -0800
Message-ID: <1330490933.4352.1.camel@joe2Laptop>
References: <1330490737-28973-1-git-send-email-mugunthanvnm@ti.com>
	 <1330490737-28973-2-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:45437 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965408Ab2B2Esz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Feb 2012 23:48:55 -0500
In-Reply-To: <1330490737-28973-2-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-29 at 10:15 +0530, Mugunthan V N wrote:
> TI CPSW ethernet switch has a built-in address lookup engine.  This patch adds
> the code necessary for programming this module.
[]
>  drivers/net/ethernet/ti/cpsw_ale.c |  638 ++++++++++++++++++++++++++++++++++++
[]
> +struct cpsw_ale *cpsw_ale_create(struct cpsw_ale_params *params)
> +{
> +	struct cpsw_ale *ale;
> +
> +	ale = kzalloc(sizeof(*ale), GFP_KERNEL);
> +	ale->params = *params;

kzalloc failure...
