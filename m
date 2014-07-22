From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7] bfin_mac: convert bfin Ethernet driver to NAPI
 framework
Date: Tue, 22 Jul 2014 09:59:44 +0200
Message-ID: <1406015984.10255.121.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406014682-19188-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	adi-buildroot-devel@lists.sourceforge.net,
	Sonic Zhang <sonic.zhang@analog.com>
To: Sonic Zhang <sonic.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37009 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaGVIAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 04:00:02 -0400
Received: by mail-wi0-f180.google.com with SMTP id n3so5291863wiv.1
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 00:59:57 -0700 (PDT)
In-Reply-To: <1406014682-19188-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-22 at 15:38 +0800, Sonic Zhang wrote:
> From: Sonic Zhang <sonic.zhang@analog.com>

> +	if (i < budget) {
> +		napi_complete(napi);
> +		if (lp->rx_irq_disabled--)
> +			if (!lp->rx_irq_disabled)
> +				enable_irq(IRQ_MAC_RX);


You wrote :

	if (A--)
		if (!A)
			something();

Isnt a bit strange ???
