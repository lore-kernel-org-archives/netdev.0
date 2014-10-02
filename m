From: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Subject: Re: [PATCH] wil6210: remove obsolete msm platform code
Date: Thu, 2 Oct 2014 14:29:06 +0300
Message-ID: <1572828.LhiMXjHRdV@lx-wigig-72>
References: <3995357.SmO1fZQuHn@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	<wil6210@qca.qualcomm.com>, <netdev@vger.kernel.org>,
	<linux-wireless@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:51825 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbaJBL3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 07:29:13 -0400
In-Reply-To: <3995357.SmO1fZQuHn@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, September 30, 2014 05:48:20 PM Arnd Bergmann wrote:
> The wil6210 driver has a glue layer for the Qualcomm MSM platform
> code, which apparently could never build and is unlikely to
> ever be able to in the future, as the MSM platform is being phased
> out in favor of the new QCOM platform, and the driver relies
> on out-of-tree infrastructure. Trying to build it currently
> results in this error:
> 
> drivers/net/wireless/ath/wil6210/wil_platform_msm.c:19:27: fatal error: linux/msm-bus.h: No such file or directory
> 
> Removing the driver fixes the build and makes it possible to
> build an allmodconfig kernel for MSM.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 

We are investigating this, looking for the appropriate solution.
Thanks for pointing to this.

Thanks, Vladimir
