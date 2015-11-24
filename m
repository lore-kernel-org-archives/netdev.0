From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] sh_eth: Remove obsolete platform_device_id
 entries
Date: Tue, 24 Nov 2015 16:48:57 -0500 (EST)
Message-ID: <20151124.164857.2104136950033442678.davem@davemloft.net>
References: <1448376060-7803-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755182AbbKXVs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 16:48:59 -0500
In-Reply-To: <1448376060-7803-1-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Tue, 24 Nov 2015 15:40:56 +0100

> Since commit 3d7608e4c169af03 ("ARM: shmobile: bockw: remove legacy
> board file and config"), which is in v4.4-rc1, shmobile SoCs are only
> supported in generic DT-only ARM multi-platform builds.  The sh_eth
> driver doesn't need to match platform devices by name anymore, hence
> this series removes the corresponding platform_device_id entries.
> 
> Changes since v2:
>   - More Acks,
>   - Platform dependency has entered mainline,
> 
> Changes since v1:
>   - Protect some data and functions by #ifdef CONFIG_OF to silence
>     unused compiler warnings on SH,
>   - New patches 3 and 4.
> 
> Thanks for applying!

Series applied to net-next, thanks!
