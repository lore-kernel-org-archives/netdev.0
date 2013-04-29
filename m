From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] be2net: FLR must be first cmd issued to
 Lancer FW
Date: Mon, 29 Apr 2013 15:16:01 -0400 (EDT)
Message-ID: <20130429.151601.1915233683350396033.davem@davemloft.net>
References: <78281116-7d1e-4aff-b59c-f9a583fa35ea@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kalesh.purayil@emulex.com
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759722Ab3D2TQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 15:16:03 -0400
In-Reply-To: <78281116-7d1e-4aff-b59c-f9a583fa35ea@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Mon, 29 Apr 2013 13:52:29 +0530

> From: Kalesh AP <kalesh.purayil@emulex.com>
> 
> Lancer FW requires that the first cmd issued by the host-driver be an FLR.
> So, re-order be_probe() to move be_cmd_function_reset() ahead of
> be_cmd_fw_init().
> 
> Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied.
