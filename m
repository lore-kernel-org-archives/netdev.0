From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: mark symbols static where possible
Date: Sun, 18 Sep 2016 13:33:32 +0200
Message-ID: <20160918133332.37f239f2@free-electrons.com>
References: <1474190445-5887-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:37146 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932253AbcIRLdk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 07:33:40 -0400
In-Reply-To: <1474190445-5887-1-git-send-email-baoyou.xie@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Sun, 18 Sep 2016 17:20:45 +0800, Baoyou Xie wrote:
> We get 2 warnings when building kernel with W=1:
> drivers/net/ethernet/marvell/mvneta.c:639:27: warning: no previous prototype for 'mvneta_get_stats64' [-Wmissing-prototypes]
> drivers/net/ethernet/marvell/mvneta.c:3529:5: warning: no previous prototype for 'mvneta_ethtool_set_link_ksettings' [-Wmissing-prototypes]
> 
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
