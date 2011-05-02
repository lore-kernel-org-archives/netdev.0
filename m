From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: don't spam dmesg with "Using LC-trie" messages
Date: Sun, 01 May 2011 23:18:03 -0700 (PDT)
Message-ID: <20110501.231803.104067615.davem@davemloft.net>
References: <20110501120411.GA5224@p183>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59153
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753900Ab1EBGSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 02:18:36 -0400
In-Reply-To: <20110501120411.GA5224@p183>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 1 May 2011 15:04:11 +0300

> fib_trie_table() is called during netns creation and
> Chromium uses clone(CLONE_NEWNET) to sandbox renderer process.
> 
> Don't print anything.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Yeah that's pretty annoying, patch applied, thanks.
