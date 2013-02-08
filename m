From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net: sctp: sctp_auth_key_put: use kzfree
 instead of kfree
Date: Thu, 07 Feb 2013 23:45:14 -0500 (EST)
Message-ID: <20130207.234514.1920724559157438386.davem@davemloft.net>
References: <cover.1360231701.git.dborkman@redhat.com>
	<cover.1360231701.git.dborkman@redhat.com>
	<8c764d916f21d56402a5b9a915ea31d927898da0.1360231701.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56764 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552Ab3BHEpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 23:45:15 -0500
In-Reply-To: <8c764d916f21d56402a5b9a915ea31d927898da0.1360231701.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu,  7 Feb 2013 11:55:37 +0100

> For sensitive data like keying material, it is common practice to zero
> out keys before returning the memory back to the allocator. Thus, use
> kzfree instead of kfree.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable.
