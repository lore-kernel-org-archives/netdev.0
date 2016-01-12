From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 16:34:53 +0100
Message-ID: <56951D1D.5080602@stressinduktion.org>
References: <5682665A.7090102@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Stas Sergeev <stsp@list.ru>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:34286 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762770AbcALPe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 10:34:57 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 754D1207D6
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 10:34:56 -0500 (EST)
In-Reply-To: <5682665A.7090102@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.12.2015 11:54, Stas Sergeev wrote:
> Hello.
>
> I was hitting a strange problem when some internet hosts
> suddenly stops responding until I reboot. ping to these
> host gives "Destination Host Unreachable". After the
> initial confusion, I've finally got to
> ip route get
> and got something quite strange.
>
>
> Example for GOOD address (the one that I can ping):
>
> ip route get 91.189.89.237
> 91.189.89.237 via 192.168.8.1 dev eth0  src 192.168.10.202
>      cache
>
>
> Example for BAD address (the one that stopped responding):
>
> ip route get 91.189.89.238
> 91.189.89.238 via 192.168.0.1 dev eth0  src 192.168.10.202
>      cache <redirected>

I tried to understand this thread and now wonder why this redirect route 
isn't there always. Can you please summarize again why this shouldn't 
happen? It looks totally fine to me from the configuration of your 
router and the subnet masks.

Bye,
Hannes
