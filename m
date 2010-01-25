From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sfc: Use fixed-size buffers for MCDI NVRAM requests
Date: Mon, 25 Jan 2010 15:50:13 -0800 (PST)
Message-ID: <20100125.155013.244358929.davem@davemloft.net>
References: <1264447852.2793.4.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33579
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751466Ab0AYXuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 18:50:01 -0500
In-Reply-To: <1264447852.2793.4.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 25 Jan 2010 19:30:52 +0000

> The low-level MCDI code always uses 32-bit MMIO operations, and
> callers must pad input and output buffers to multiples of 4 bytes.
> The MCDI NVRAM functions are not doing this.  Also, their buffers are
> declared as variable-length arrays with no explicit maximum length.
> 
> Switch to a fixed buffer size based on the chunk size used by the
> MTD driver (which is a multiple of 4).
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
