From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: fix slab corruption from use after free
 on INIT collisions
Date: Mon, 26 Jan 2015 17:05:10 -0800 (PST)
Message-ID: <20150126.170510.1181175198992396635.davem@davemloft.net>
References: <1421947614-31407-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757394AbbA0BFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 20:05:10 -0500
In-Reply-To: <1421947614-31407-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 22 Jan 2015 18:26:54 +0100

> When hitting an INIT collision case during the 4WHS with AUTH enabled, as
> already described in detail in commit 1be9a950c646 ("net: sctp: inherit
> auth_capable on INIT collisions"), it can happen that we occasionally
> still remotely trigger the following panic on server side which seems to
> have been uncovered after the fix from commit 1be9a950c646 ...
 ...
> Fixes: 730fc3d05cd4 ("[SCTP]: Implete SCTP-AUTH parameter processing")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, thanks.
