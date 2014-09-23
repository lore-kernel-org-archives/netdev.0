From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 3/9] Documentation: bindings: net: add the Marvell PXA168 Ethernet controller
Date: Tue, 23 Sep 2014 16:37:17 +0200
Message-ID: <4014272.rJbSfrLcuB@wuerfel>
References: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com> <20140923140113.GC18924@kwain> <20140923142922.GE18924@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
	jszhang@marvell.com, sebastian.hesselbarth@gmail.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:52479 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755953AbaIWOh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 10:37:29 -0400
In-Reply-To: <20140923142922.GE18924@kwain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 23 September 2014 16:29:22 Antoine Tenart wrote:
> 
> So I had a look on other Ethernet bindings. Would you agree with
> something like the following?
> 
>         eth0: ethernet@f7b90000 {
>                 ...
>                 #address-cells = <1>;
>                 #size-cells = <0>;
>                 phy-handle = <&ethphy0>;
> 
>                 ethphy0: ethernet-phy@0 {
>                         reg = <0>;
>                 };
>         };

Yes, that looks good.

	Arnd
