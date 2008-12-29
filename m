From: Dave Jones <davej@redhat.com>
Subject: 2.6.28-git1 gianfar compile failure (ppc).
Date: Mon, 29 Dec 2008 00:41:23 -0500
Message-ID: <20081229054026.GA14962@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dai Haruki <dai.haruki@freescale.com>,
	Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43483 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbYL2FoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 00:44:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ERROR: "cacheable_memzero" [drivers/net/gianfar_driver.ko] undefined!

Introduced in a22823e72a4821ce1d4a248fbd8f5a81795af339

I guess that needs exporting for when gianfar is modular, but I've no
idea how to export things from powerpc assembly.

	Dave

-- 
http://www.codemonkey.org.uk
