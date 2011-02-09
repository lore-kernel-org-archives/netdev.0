From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] pch_gbe: Fix the issue which a driver locks when rx
 offload is set by ethtool
Date: Wed, 09 Feb 2011 12:28:17 -0800 (PST)
Message-ID: <20110209.122817.193697348.davem@davemloft.net>
References: <4D524C7F.1000700@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, tomoya-linux@dsn.okisemi.com
To: toshiharu-linux@dsn.okisemi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D524C7F.1000700@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Date: Wed, 09 Feb 2011 17:12:47 +0900

> This driver will be in a deadlock, When the rx offload is set by ethtool.
> The pch_gbe_reinit_locked function was modified.
> 
> Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>

Applied.
