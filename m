From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
Date: 23 Mar 2008 20:15:24 +0100
Message-ID: <87y7896ylv.fsf@basil.nowhere.org>
References: <47BDC848.50607@cosmosbay.com>
	<20080226.182120.183405235.davem@davemloft.net>
	<47C92F49.4070100@cosmosbay.com>
	<20080323.032949.194309002.davem@davemloft.net>
	<47E6A5FD.6060407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.alice-dsl.net ([88.44.63.5]:7444 "EHLO
	smtp-out03.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754262AbYCWT3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 15:29:37 -0400
In-Reply-To: <47E6A5FD.6060407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> writes:
> 
> What we call 4K stacks is in fact 4K - sizeof(struct task_struct), so

Actually it is 4K - sizeof(struct thread_struct). 

> a litle bit more than 2K. (not counting some insane configuration were
> struct task_struct take 3.5 KB, see CONFIG_LATENCYTOP for an example)

thread_struct significantly smaller than task_struct

That said I agree that 4K stack is too tight for many things
and in general dangerous.

-Andi
