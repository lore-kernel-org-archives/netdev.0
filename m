From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] bnxt_en: New Broadcom ethernet driver.
Date: Sun, 18 Oct 2015 22:17:56 -0700
Message-ID: <20151018221756.37849ea3@xeon-e3>
References: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <prashant@broadcom.com>,
	<eddie.wai@broadcom.com>, <huangjw@broadcom.com>,
	<netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35647 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836AbbJSFRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 01:17:46 -0400
Received: by pasz6 with SMTP id z6so18756233pas.2
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 22:17:45 -0700 (PDT)
In-Reply-To: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 Oct 2015 00:21:44 -0400
Michael Chan <mchan@broadcom.com> wrote:

> +/* indexed by enum above */
> +static struct {
> +	char *name;
> +} board_info[] = {
> +	{ "Broadcom BCM57302 NetXtreme-C Single-port 10Gb/25Gb/40Gb/50Gb Ethernet" },
> +	{ "Broadcom BCM57304 NetXtreme-C Dual-port 10Gb/25Gb/40Gb/50Gb Ethernet" },
> +	{ "Broadcom BCM57404 NetXtreme-E Dual-port 10Gb/25Gb Ethernet" },
> +	{ "Broadcom BCM57406 NetXtreme-E Dual-port 10Gb Ethernet" },
> +	{ "Broadcom BCM57304 NetXtreme-C Ethernet Virtual Function" },
> +	{ "Broadcom BCM57404 NetXtreme-E Ethernet Virtual Function" },
> +};

Tables like this should be declared const.
