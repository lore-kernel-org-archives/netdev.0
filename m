From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/6] ipv4/fib_trie: Cleanups to prepare for
 introduction of key vector
Date: Wed, 04 Mar 2015 12:53:27 -0500 (EST)
Message-ID: <20150304.125327.2002716390225095168.davem@davemloft.net>
References: <20150302212637.1490.33609.stgit@ahduyck-vm-fedora20>
	<20150304.001640.1653151786060996185.davem@davemloft.net>
	<54F71BEF.5030706@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932408AbbCDRxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 12:53:31 -0500
In-Reply-To: <54F71BEF.5030706@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 04 Mar 2015 06:51:27 -0800

> If bits can be 32 then idx should be an unsigned long which is 64
> bits.

unsigned long is 32-bit on 32-bit platforms
