From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH][NET] gianfar: fix obviously wrong #ifdef CONFIG_GFAR_NAPI placement
Date: Thu, 18 Oct 2007 10:40:13 +0100
Message-ID: <20071018094013.GU21136@shadowen.org>
References: <20071017195746.GA15592@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: leoli@freescale.com, jgarzik@pobox.com, paulus@samba.org,
	galak@kernel.crashing.org, afleming@freescale.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hellhawk.shadowen.org ([80.68.90.175]:4447 "EHLO
	hellhawk.shadowen.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755528AbXJRJk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 05:40:28 -0400
Content-Disposition: inline
In-Reply-To: <20071017195746.GA15592@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The check then is to see if a non {}'d block has no statements in it if the
ifdef is null.  Hmmm.  May be possible.  Will think on it.

        if (err)
+#ifdef CONFIG_GFAR_NAPI
                napi_disable(&priv->napi);
+#endif

-apw
