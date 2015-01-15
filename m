From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v13 3/3] net: hisilicon: new hip04 ethernet driver
Date: Thu, 15 Jan 2015 13:30:13 +0100
Message-ID: <1848773.hOchPbb3Eb@wuerfel>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com> <1421253246.11734.17.camel@edumazet-glaptop2.roam.corp.google.com> <54B796A3.7040200@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, robh+dt@kernel.org,
	davem@davemloft.net, grant.likely@linaro.org, agraf@suse.de,
	sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, xuwei5@hisilicon.com,
	zhangfei.gao@linaro.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:62236 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbbAOMa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 07:30:58 -0500
In-Reply-To: <54B796A3.7040200@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 January 2015 18:29:55 Ding Tianhong wrote:
> 
> Yes, thanks, fix them later.

Please note that now that as v13 has now shown up in net-next, I guess
all other patches need to be based on top of what is already merged,
and address one issue at a time.

There is one more issue I saw during build testing, which is the
lack of a MODULE_LICENSE  statement for the main driver, although
there is one in the mdio driver.

	Arnd
