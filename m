From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] pppoe: Lacks DST MAC address check
Date: Mon, 20 Apr 2015 15:27:28 -0400 (EDT)
Message-ID: <20150420.152728.2303510459953341238.davem@davemloft.net>
References: <1429556868-28640-1-git-send-email-joakim.tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbbDTT1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 15:27:32 -0400
In-Reply-To: <1429556868-28640-1-git-send-email-joakim.tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Date: Mon, 20 Apr 2015 21:07:48 +0200

> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> 
> A pppoe session is identified by its session ID and MAC address.
> Currently pppoe does not check if the received pkg has the correct
> MAC address. This is a problem when the eth I/F is in promisc mode
> as then any DST MAC address is accepted.
> 
> Signed-off-by: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> ---
>  drivers/net/ppp/pppoe.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> v2 - The MAC address check should encompass all pppoe pkgs,
>      not only the relay type.
> 
> v3 - Add signoff

Applied, thanks.
