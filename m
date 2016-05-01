From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] soreuseport: Fix TCP listener hash collision
Date: Sun, 01 May 2016 19:38:05 -0400 (EDT)
Message-ID: <20160501.193805.651325884144750958.davem@davemloft.net>
References: <1461885872-27358-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbcEAXiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 19:38:06 -0400
In-Reply-To: <1461885872-27358-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Thu, 28 Apr 2016 19:24:32 -0400

> From: Craig Gallek <kraig@google.com>
> 
> I forgot to include a check for listener port equality when deciding
> if two sockets should belong to the same reuseport group.  This was
> not caught previously because it's only necessary when two listening
> sockets for the same user happen to hash to the same listener bucket.
> The same error does not exist in the UDP path.
> 
> Fixes: c125e80b8868("soreuseport: fast reuseport TCP socket selection")
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied.
