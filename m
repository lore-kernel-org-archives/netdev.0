From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next PATCH 2] net: ethernet driver: Fujitsu OGMA
Date: Tue, 10 Jun 2014 10:29:13 -0700
Message-ID: <20140610102913.44cfa610@nehalam.linuxnetplumber.net>
References: <20140610010803.18695.88446.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	patches@linaro.org
To: Andy Green <andy.green@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:40923 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135AbaFJR3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 13:29:16 -0400
Received: by mail-pd0-f178.google.com with SMTP id v10so6284859pde.37
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 10:29:16 -0700 (PDT)
In-Reply-To: <20140610010803.18695.88446.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jun 2014 09:08:03 +0800
Andy Green <andy.green@linaro.org> wrote:

> +static void ogma_ethtool_get_drvinfo(struct net_device *net_device,
> +				     struct ethtool_drvinfo *drvinfo)
> +{
> +}
> +

Either, fill in some basic info in this function, or don't support
ethtool at all.
