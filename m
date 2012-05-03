From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ucc_geth: Add 16 bytes to max TX frame for VLANs
Date: Wed, 02 May 2012 20:12:35 -0400 (EDT)
Message-ID: <20120502.201235.1329621426123380213.davem@davemloft.net>
References: <1335775015-14718-1-git-send-email-Joakim.Tjernlund@transmode.se>
	<1335775015-14718-2-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim.Tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407Ab2ECAMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:12:43 -0400
In-Reply-To: <1335775015-14718-2-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Mon, 30 Apr 2012 10:36:55 +0200

> Creating a VLAN interface on top of ucc_geth adds 4 bytes
> to the frame and the HW controller is not prepared to
> TX a frame bigger than 1518 bytes which is 4 bytes too
> small for a full VLAN frame. Add 16 bytes which will handle
> the a simple VLAN and leaves 12 bytes for future expansion.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Applied.
