From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v3 10/13] net; ethernet: ti: cpsw: move irq stuff under
 cpsw_common
Date: Wed, 10 Aug 2016 21:14:51 +0530
Message-ID: <d6a1422c-3631-0ab4-1971-8703222016f2@ti.com>
References: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470784964-26440-11-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<netdev@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:56665 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932173AbcHJSCR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 14:02:17 -0400
In-Reply-To: <1470784964-26440-11-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 August 2016 04:52 AM, Ivan Khoronzhuk wrote:
> The irq data are common for net devs in dual_emac mode. So no need to
> hold these data in every priv struct, move them under cpsw_common.
> Also delete irq_num var, as after optimization it's not needed.
> Correct number of irqs to 2, as anyway, driver is using only 2,
> at least for now.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
