From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ptp: reduce stack usage when reading
 external time stamps
Date: Mon, 26 Nov 2012 17:23:29 -0500 (EST)
Message-ID: <20121126.172329.619135499941355889.davem@davemloft.net>
References: <20121102020631.GI16883@yliu-dev.sh.intel.com>
	<1146e32bcb835ebf394bab91db3161600ab5213a.1353929829.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757277Ab2KZWXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 17:23:33 -0500
In-Reply-To: <1146e32bcb835ebf394bab91db3161600ab5213a.1353929829.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Mon, 26 Nov 2012 12:44:34 +0100

> This patch removes the large buffer from the stack of the read file
> operation and replaces it with a kmalloced buffer.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Applied.
