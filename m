From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 38 of 39] IB/ipath - More changes to support InfiniPath
 on PowerPC 970 systems
Date: Thu, 29 Jun 2006 14:53:19 -0700 (PDT)
Message-ID: <20060629.145319.71091846.davem@davemloft.net>
References: <patchbomb.1151617251@eng-12.pathscale.com>
	<c22b6c244d5db77f7b1d.1151617289@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, rdreier@cisco.com, mst@mellanox.co.il,
	openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61134
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932967AbWF2VyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 17:54:06 -0400
To: bos@pathscale.com
In-Reply-To: <c22b6c244d5db77f7b1d.1151617289@eng-12.pathscale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bryan O'Sullivan <bos@pathscale.com>
Date: Thu, 29 Jun 2006 14:41:29 -0700

>  ipath_core-$(CONFIG_X86_64) += ipath_wc_x86_64.o
> +ipath_core-$(CONFIG_PPC64) += ipath_wc_ppc64.o

Again, don't put these kinds of cpu specific functions
into the infiniband driver.  They are potentially globally
useful, not something only Infiniband might want to do.
