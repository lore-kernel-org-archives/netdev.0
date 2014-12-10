From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8 3/3] net: hisilicon: new hip04 ethernet driver
Date: Wed, 10 Dec 2014 12:02:44 -0500 (EST)
Message-ID: <20141210.120244.722990295139076460.davem@davemloft.net>
References: <2331317.LV3gPP3odb@wuerfel>
	<20141210.110732.519666115784722516.davem@davemloft.net>
	<34612839.hAkXUcbKUQ@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	linux@arm.linux.org.uk, eric.dumazet@gmail.com,
	sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	agraf@suse.de, xuwei5@hisilicon.com, David.Laight@aculab.com,
	dingtianhong@huawei.com, zhangfei.gao@linaro.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755312AbaLJRCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 12:02:49 -0500
In-Reply-To: <34612839.hAkXUcbKUQ@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 10 Dec 2014 17:36:46 +0100

> Or is there any better alternative for broken hardware that lacks
> a TX-complete interrupt?

The only option is an hrtimer or similar.
