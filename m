From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/6] tipc: refcount and memory leak fixes
Date: Thu, 06 Mar 2014 14:47:14 -0500 (EST)
Message-ID: <20140306.144714.915091981153232193.davem@davemloft.net>
References: <1394113221-30100-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com,
	paul.gortmaker@windriver.com, richard.alpe@ericsson.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbaCFTrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 14:47:17 -0500
In-Reply-To: <1394113221-30100-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Thu, 6 Mar 2014 14:40:15 +0100

> v3: Remove error logging from data path completely. Rebased on top of
>     latest net merge.
> 
> v2: Drop specific -ENOMEM logging in patch #1 (tipc: allow connection
>     shutdown callback to be invoked in advance) And add a general error
>     message if an internal server tries to send a message on a
>     closed/nonexisting connection.
> 
> In addition to the fix for refcount leak and memory leak during
> module removal, we also fix a problem where the topology server
> listening socket where unexpectedly closed. We also eliminate an
> unnecessary context switch during accept()/recvmsg() for nonblocking
> sockets.
> 
> It might be good to include this patchset in stable aswell. After the 
> v3 rebase on latest merge from net all patches apply cleanly on that
> tree.

Series applied and queued up for -stable, thanks.
