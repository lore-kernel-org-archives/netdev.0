From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] packet: doc: describe PACKET_MMAP with one
 packet socket for rx and tx
Date: Fri, 10 Jan 2014 17:58:11 -0500 (EST)
Message-ID: <20140110.175811.1139439658496998152.davem@davemloft.net>
References: <1389345757-13579-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nvbolhuis@aimvalley.nl
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbaAJW6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 17:58:12 -0500
In-Reply-To: <1389345757-13579-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 10 Jan 2014 10:22:37 +0100

> From: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
> 
> Document how to use one AF_PACKET mmap socket for RX and TX.
> 
> Signed-off-by: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Don't you need to evaluate need_rehook with at least the socket
lock held?

Otherwise how would two parallel bind() calls pan out?
