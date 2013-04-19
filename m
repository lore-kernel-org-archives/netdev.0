From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] packet: move hw/sw timestamp extraction
 into a small helper
Date: Fri, 19 Apr 2013 16:50:47 -0400 (EDT)
Message-ID: <20130419.165047.1719206786638234482.davem@davemloft.net>
References: <1366111751-14886-1-git-send-email-dborkman@redhat.com>
	<1366111751-14886-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, hawk@diku.dk
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932333Ab3DSUut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:50:49 -0400
In-Reply-To: <1366111751-14886-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 16 Apr 2013 13:29:11 +0200

> This patch introduces a small, internal helper function, that is used by
> PF_PACKET. Based on the flags that are passed, it extracts the packet
> timestamp in the receive path. This is merely a refactoring to remove
> some duplicate code in tpacket_rcv(), to make it more readable, and to
> enable others to use this function in PF_PACKET as well, e.g. for TX.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
