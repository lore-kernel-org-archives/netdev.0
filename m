From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Fix single-vector MSI-X code
Date: Tue, 17 Jan 2012 23:56:40 -0500 (EST)
Message-ID: <20120117.235640.1394063282901449922.davem@davemloft.net>
References: <1326850043-23417-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757174Ab2ARE4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 23:56:43 -0500
In-Reply-To: <1326850043-23417-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Tue, 17 Jan 2012 17:27:23 -0800

> Kdump kernels leave MSI-X interrupts (as setup by the crashed kernel)
> enabled.  However, kdump only enables one CPU in the new environment,
> thus causing tg3 to abort MSI-X setup.  When the driver attempts to
> enable INTA or MSI interrupt modes on a kdump kernel, interrupt
> delivery fails.
> 
> This patch attempts to workaround the problem by forcing the driver
> to enable a single MSI-X interrupt.  In such a configuration, the
> device's multivector interrupt mode must be disabled.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

Applied.
