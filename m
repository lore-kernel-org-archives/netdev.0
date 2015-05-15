From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 00/11] convert stmmac glue layers into
 platform drivers
Date: Fri, 15 May 2015 12:44:46 -0400 (EDT)
Message-ID: <20150515.124446.727849098381931716.davem@redhat.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, peppe.cavallaro@st.com, roger.chen@rock-chips.com,
	wens@csie.org, srinivas.kandagatla@st.com,
	dinguyen@opensource.altera.com, b.galvani@gmail.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-rockchip@lists.infradead.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752701AbbEOQov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 12:44:51 -0400
In-Reply-To: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Thu, 14 May 2015 12:10:55 +0200

> This patch set aims to convert the current dwmac glue layers into
> proper platform drivers as request by Arnd[1]. These changes start
> from patch 3 and onwards.
> 
> Overview:
> Platform driver functions like probe and remove are exported from
> the stmmac platform and then used in subsequent glue later
> conversions. The conversion involes adding the platform driver
> boiler plate code and adding it to the build system. The last patch
> removes the driver from the stmmac platform code thus making it into
> a library for common platform driver functions.
> 
> The two first patches adds glue layer for my platform. I chose to
> first add old style glue layer and then convert it. The churn this
> creates is just 3 lines.
> 
> I would be very nice if people could test this patch set on their
> respective platform. My testing has been limited to compiling and
> testing on my (LPC18xx) platform. Thanks!
> 
> Next I will look into cleaning up the stmmac platform code.
> 
> [1] http://marc.info/?l=linux-arm-kernel&m=143059524606459&w=2

Series applied, thanks Joachim.
