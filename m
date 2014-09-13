From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: filter: constify detection of
 pkt_type_offset
Date: Sat, 13 Sep 2014 17:08:24 -0400 (EDT)
Message-ID: <20140913.170824.959567788304681370.davem@davemloft.net>
References: <5412D9B9.2020300@redhat.com>
	<5412D9B9.2020300@redhat.com>
	<3e68956a7e5b8bb9de226bfcc09092c6852a0a0a.1410523297.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	markos.chandras@imgtec.com, schwidefsky@de.ibm.com,
	dborkman@redhat.com, alexei.starovoitov@gmail.com,
	kda@linux-powerpc.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38146 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbaIMVI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 17:08:26 -0400
In-Reply-To: <3e68956a7e5b8bb9de226bfcc09092c6852a0a0a.1410523297.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 12 Sep 2014 14:04:43 +0200

> Currently we have 2 pkt_type_offset functions doing the same thing and
> spread across the architecture files. Remove those and replace them
> with a PKT_TYPE_OFFSET macro helper which gets the constant value from a
> zero sized sk_buff member right in front of the bitfield with offsetof.
> This new offset marker does not change size of struct sk_buff.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Markos Chandras <markos.chandras@imgtec.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> 
> v2) Incorporated Daniel's feedback. I first misinterpreted the feedback
>     as something not related to pkt_type_offset.

Applied, thanks.
