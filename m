From: David Miller <davem@davemloft.net>
Subject: Re: UDP/bnx2: inconsistent lock state
Date: Thu, 30 Oct 2008 14:01:34 -0700 (PDT)
Message-ID: <20081030.140134.68573546.davem@davemloft.net>
References: <a4423d670810300340i27cd7fe3wea42767431ad3574@mail.gmail.com>
	<4909B4D9.20807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.beregalov@gmail.com, mchan@broadcom.com,
	linux-next@vger.kernel.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52298
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754227AbYJ3VCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 17:02:00 -0400
In-Reply-To: <4909B4D9.20807@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 30 Oct 2008 14:21:29 +0100

> [PATCH] udp: Should use spin_lock_bh()/spin_unlock_bh() in udp_lib_unhash()
> 
> Spotted by Alexander Beregalov
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks for fixing this so quickly Eric.
