From: David Miller <davem@davemloft.net>
Subject: Re: RCU lock bug in 3.0.21 (bisected to: 682cb56a, fix NULL
 dereferences in check_peer_redir)
Date: Mon, 26 Mar 2012 17:49:45 -0400 (EDT)
Message-ID: <20120326.174945.1186427809261872546.davem@davemloft.net>
References: <4F70E308.7070908@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	gregkh@linuxfoundation.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35024 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757302Ab2CZVtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 17:49:50 -0400
In-Reply-To: <4F70E308.7070908@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Looks like all of those strange undiagnosable reported Dave Jones
has been feeding us.  Something in one part of the kernel leaves
a lock held, and this shows up as a warning elsewhere.
