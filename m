From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tipc: fix message importance range check
Date: Sat, 16 Aug 2014 20:17:55 -0700 (PDT)
Message-ID: <20140816.201755.717945178998298041.davem@davemloft.net>
References: <1408113875-30655-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	richard.alpe@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbaHQDRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2014 23:17:40 -0400
In-Reply-To: <1408113875-30655-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Fri, 15 Aug 2014 16:44:35 +0200

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> Commit 3b4f302d8578 ("tipc: eliminate
> redundant locking") introduced a bug by removing the sanity check
> for message importance, allowing programs to assign any value to
> the msg_user field. This will mess up the packet reception logic
> and may cause random link resets.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>

Applied, thank you.
