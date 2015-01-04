From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] rhashtable: fix missing header
Date: Sun, 4 Jan 2015 09:19:08 +0000
Message-ID: <20150104091908.GA15305@casper.infradead.org>
References: <1420356309-7382-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39539 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbbADJTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 04:19:12 -0500
Content-Disposition: inline
In-Reply-To: <1420356309-7382-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/15 at 03:25pm, Ying Xue wrote:
> Fixup below build error:
> 
> include/linux/rhashtable.h: At top level:
> include/linux/rhashtable.h:118:34: error: field ???mutex??? has incomplete type

Just wondering, is this your new code that didn't compile? The code
compiled fine for me for the existing users.

> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Fixes: 97defe1e ("rhashtable: Per bucket locks & deferred expansion/shrinking")
Acked-by: Thomas Graf <tgraf@suug.ch>
