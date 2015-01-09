From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/3] rhashtable: add a note for grow and shrink
 decision functions
Date: Fri, 9 Jan 2015 10:31:58 +0000
Message-ID: <20150109103158.GA1523@casper.infradead.org>
References: <1420791818-22150-1-git-send-email-ying.xue@windriver.com>
 <1420791818-22150-4-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51704 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904AbbAIKb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 05:31:59 -0500
Content-Disposition: inline
In-Reply-To: <1420791818-22150-4-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/15 at 04:23pm, Ying Xue wrote:
> As commit c0c09bfdc415 ("rhashtable: avoid unnecessary wakeup for
> worker queue") moves condition statements of verifying whether hash
> table size exceeds its maximum threshold or reaches its minimum
> threshold from resizing functions to resizing decision functions,
> we should add a note in rhashtable.h to indicate the implementation
> of what the grow and shrink decision function must enforce min/max
> shift, otherwise, it's failed to take min/max shift's set watermarks
> into effect.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Thomas Graf <tgraf@suug.ch>

Acked-by: Thomas Graf <tgraf@suug.ch>
