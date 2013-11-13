From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 1/3] can: mcp251x: Convert driver to use common clk
 framework
Date: Wed, 13 Nov 2013 17:59:01 +0000 (UTC)
Message-ID: <l60el5$2kn$1@ger.gmane.org>
References: <1384332144-15211-1-git-send-email-shc_work@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-can@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:38813 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753522Ab3KMR7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 12:59:23 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Vgein-0005kO-Q6
	for netdev@vger.kernel.org; Wed, 13 Nov 2013 18:59:21 +0100
Received: from ppp91-122-11-187.pppoe.avangarddsl.ru ([91.122.11.187])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 18:59:21 +0100
Received: from dbaryshkov by ppp91-122-11-187.pppoe.avangarddsl.ru with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 18:59:21 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Nov 2013 12:42:24 +0400, Alexander Shiyan wrote:

> This patch converts mcp251x driver to using common clk framework for
> getting input frequency. The change was made for the preparation of the
> driver work with the devicetree. As a result private header for the
> driver is eliminated.
> Additionally, all existing users of the driver was converted to use this
> feature.


PXA does not employ COMMON_CLK yet (WIP locally, but it is not finished 
yet), so clk_register_fixed() will probably fail.

-- 
With best wishes
Dmitry
