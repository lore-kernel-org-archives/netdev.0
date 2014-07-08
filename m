From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: fix bug in multicast/broadcast message
 reassembly
Date: Tue, 08 Jul 2014 15:55:42 -0700 (PDT)
Message-ID: <20140708.155542.2880546866748428.davem@davemloft.net>
References: <1404582253-21815-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726AbaGHWzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 18:55:46 -0400
In-Reply-To: <1404582253-21815-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Sat,  5 Jul 2014 13:44:13 -0400

> Since commit 37e22164a8a3c39bdad45aa463b1e69a1fdf4110 ("tipc: rename and
> move message reassembly function") reassembly of long broadcast messages
> has been broken. This is because we test for a non-NULL return value
> of the *buf parameter as criteria for succesful reassembly. However, this
> parameter is left defined even after reception of the first fragment,
> when reassebly is still incomplete. This leads to a kernel crash as soon
> as a the first fragment of a long broadcast message is received.
> 
> We fix this with this commit, by implementing a stricter behavior of the
> function and its return values.
> 
> This commit should be applied to both net and net-next.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.
