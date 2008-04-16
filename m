From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Discard tcp out-of-order queue if system limit is reached
Date: Wed, 16 Apr 2008 09:01:45 +0200
Message-ID: <4805A459.5050706@firstfloor.org>
References: <200804151854.45021.vgusev@openvz.org> <20080415.202740.114756353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:40378 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbYDPHCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 03:02:43 -0400
In-Reply-To: <20080415.202740.114756353.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Vitaliy Gusev <vgusev@openvz.org>
> Date: Tue, 15 Apr 2008 18:54:44 +0400
> 
>> tcp_prune_queue() doesn't prune an out-of-order queue if socket
>> is under rcvbuf. However even if socket is under rcvbuf but system-wide limit is
>> reached then skb cannot be queued. It can lead to deadlock situation as any skb that
>> fills sequence hole is dropped.
>> So discard out-of-order queue if system-wide limit is reached.
>>
>> Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>
> 
> I applied your original patch already, so I added the following
> relative patch.

Could you please at least update the original description to the
one from the new patch? That one was somewhat misleading imho.

-Andi

