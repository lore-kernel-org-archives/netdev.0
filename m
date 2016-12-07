From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers: net: cpsw-phy-sel: Clear RGMII_IDMODE on
 "rgmii" links
Date: Wed, 07 Dec 2016 13:12:29 -0500 (EST)
Message-ID: <20161207.131229.1181078063219041475.davem@davemloft.net>
References: <20161206.113630.1454582039498444818.davem@davemloft.net>
        <1481050611-29698-1-git-send-email-alex.g@adaptrum.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, gokhan@adaptrum.com
To: alex.g@adaptrum.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481050611-29698-1-git-send-email-alex.g@adaptrum.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexandru Gagniuc <alex.g@adaptrum.com>
Date: Tue,  6 Dec 2016 10:56:51 -0800

> Support for setting the RGMII_IDMODE bit was added in the commit
> referenced below. However, that commit did not add the symmetrical
> clearing of the bit by way of setting it in "mask". Add it here.
> 
> Note that the documentation marks clearing this bit as "reserved",
> however, according to TI, support for delaying the clock does exist in
> the MAC, although it is not officially supported.
> We tested this on a board with an RGMII to RGMII link that will not
> work unless this bit is cleared.
> 
> Fixes: 0fb26c3063ea ("drivers: net: cpsw-phy-sel: add support to configure rgmii internal delay")
> Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>

Applied.
