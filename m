From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] be2net: Fix crash on 2nd invocation of PCI
 AER/EEH error_detected hook
Date: Thu, 30 May 2013 16:58:37 -0700 (PDT)
Message-ID: <20130530.165837.906560952023831713.davem@davemloft.net>
References: <43df230c-ad73-414a-8de0-2c4f9a5f3d71@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kalesh.purayil@emulex.com
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646Ab3E3X6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 19:58:38 -0400
In-Reply-To: <43df230c-ad73-414a-8de0-2c4f9a5f3d71@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Thu, 30 May 2013 14:26:17 +0530

> During a PCI EEH/AER error recovery flow, if the device did not successfully
> restart, the error_detected() hook may be called a second time with a
> "perm_failure" state. This patch skips over driver cleanup for the second
> invocation of the callback.
> 
> Also, Lancer error recovery code is fixed-up to handle these changes.
> 
> Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
> Signed-off-by: Somnath kotur <somnath.kotur@emulex.com>

Applied.
