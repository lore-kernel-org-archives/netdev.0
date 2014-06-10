From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next PATCH 2] net: ethernet driver: Fujitsu OGMA
Date: Tue, 10 Jun 2014 10:24:20 -0700
Message-ID: <20140610102420.45435c88@nehalam.linuxnetplumber.net>
References: <20140610010803.18695.88446.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	patches@linaro.org
To: Andy Green <andy.green@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:55963 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbaFJRYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 13:24:24 -0400
Received: by mail-pa0-f51.google.com with SMTP id ey11so929501pad.10
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 10:24:23 -0700 (PDT)
In-Reply-To: <20140610010803.18695.88446.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jun 2014 09:08:03 +0800
Andy Green <andy.green@linaro.org> wrote:

> +static struct net_device_stats *ogma_netdev_get_stats(struct net_device
> +						      *net_device)
> +{
> +	return &net_device->stats;
> +}

This stub is unnecessary, if .ndo_get_stats is NULL, that is what core
code does already.
