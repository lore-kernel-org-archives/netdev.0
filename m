From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ] netem: Fix off-by-one bug in reordering
Date: Sun, 22 Jan 2012 14:23:39 -0500 (EST)
Message-ID: <20120122.142339.65185634889852412.davem@davemloft.net>
References: <1327004459-19275-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48938 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227Ab2AVTXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:23:42 -0500
In-Reply-To: <1327004459-19275-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Thu, 19 Jan 2012 12:20:59 -0800

> With netem reordering, a gap of N is supposed to reorder every Nth packet with
> given reorder probability.  However, the code currently skips N packets and
> reorders every (N+1)th packet.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Applied.
