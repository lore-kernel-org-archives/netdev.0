From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: Remove some spurious dropped packet profile
 hits from the passive connection accept path
Date: Thu, 20 Nov 2014 13:51:29 -0800
Message-ID: <546E6261.700@hp.com>
References: <20141120185829.986CB290095D@tardy> <1416516423.8629.43.camel@edumazet-glaptop2.roam.corp.google.com> <546E5DAF.5090907@hp.com> <1416520109.8629.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2352.austin.hp.com ([15.217.128.51]:48270 "EHLO
	g2t2352.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756063AbaKTVvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 16:51:31 -0500
In-Reply-To: <1416520109.8629.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2014 01:48 PM, Eric Dumazet wrote:
> On Thu, 2014-11-20 at 13:31 -0800, Rick Jones wrote:
>
>> Do you mean when there is actually data in the SYN?
>
> No, I mean the packet can be _dropped_ here, really.
>
> SYN flood for example.

Ah.  I did not pick-up on that.  Seeing the kfree_skb() in the original 
code I thought it was the end of the line for the segment.

rick
