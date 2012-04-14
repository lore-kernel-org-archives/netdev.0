From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp:Remove redundant code entering quickack
 mode
Date: Sat, 14 Apr 2012 15:26:48 -0400 (EDT)
Message-ID: <20120414.152648.456086723360721254.davem@davemloft.net>
References: <1334359439-10147-1-git-send-email-subramanian.vijay@gmail.com>
	<20120414020103.302f2c66@asterix.rh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, netdev@vger.kernel.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859Ab2DNT0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 15:26:51 -0400
In-Reply-To: <20120414020103.302f2c66@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Sat, 14 Apr 2012 02:01:03 -0300

> On Fri, 13 Apr 2012 16:23:59 -0700
> Vijay Subramanian <subramanian.vijay@gmail.com> wrote:
> 
>> tcp_enter_quickack_mode() already calls tcp_incr_quickack() and sets
>> icsk->icsk_ack.ato  to TCP_ATO_MIN. This patch removes the duplication.
>> 
>> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> 
> Reviewed-by: Flavio Leitner <fbl@redhat.com>

Applied.
