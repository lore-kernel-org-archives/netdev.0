From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/7] replace devm_request_and_ioremap by devm_ioremap_resource
Date: Mon, 19 Aug 2013 13:20:34 +0200
Message-ID: <1376911241-27720-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org,
	linux-pci@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linux-mmc@vger.kernel.org
To: linux-fbdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

devm_request_and_ioremap has been replaced by devm_ioremap_resource, which
gives more informative error return code information.  This patch series
removes the remaining uses of devm_request_and_ioremap.

This patch series was generated using the semantic patch
scripts/coccinelle/api/devm_ioremap_resource.cocci from the Linux kernel
source tree.  Manual modifications have been made to move associated calls
to platform_get_resource closer to the resulting call to
devm_ioremap_resource and to remove the associated error handling code.
