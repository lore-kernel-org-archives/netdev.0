From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cpts: Add includes for ETH_HLEN and VLAN_HLEN
 definitions
Date: Thu, 03 Apr 2014 12:32:19 -0400 (EDT)
Message-ID: <20140403.123219.186974875530426005.davem@davemloft.net>
References: <20140403160843.GD15134@hansolo.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jwboyer@fedoraproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140403160843.GD15134@hansolo.jdub.homelinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Boyer <jwboyer@fedoraproject.org>
Date: Thu, 3 Apr 2014 12:08:43 -0400

> If CONFIG_TI_CPTS is enabled, the ti_cpsw driver will fail to build with:
> 
> drivers/net/ethernet/ti/cpts.c: In function 'cpts_match':
> drivers/net/ethernet/ti/cpts.c:266:12: error: 'ETH_HLEN' undeclared (first use in this function)
>    offset = ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
>             ^
> drivers/net/ethernet/ti/cpts.c:266:12: note: each undeclared identifier is reported only once for each function it appears in
> drivers/net/ethernet/ti/cpts.c:276:23: error: 'VLAN_HLEN' undeclared (first use in this function)
>    offset = ETH_HLEN + VLAN_HLEN;
>                        ^
> 
> Add includes of if_ether.h and if_vlan.h to bring in the appropriate defines.
> 
> Signed-off-by: Josh Boyer <jwboyer@fedoraproject.org>

A patch for this was already submitted to netdev and applied to the 'net'
GIT tree earlier today.
