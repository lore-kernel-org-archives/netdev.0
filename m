From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next-2.6] sched: use xps information for qdisc NUMA affinity
Date: Tue, 30 Nov 2010 10:31:48 -0800
Message-ID: <AANLkTimU+7aY0DZrnBtL=BsP_qGpCsBw0d4TCKOJSzRL@mail.gmail.com>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
	<1290705163.4274.12.camel@localhost>
	<1291054477.3435.1302.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:51506 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab0K3Sbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 13:31:51 -0500
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id oAUIVoA7001109
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 10:31:50 -0800
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz9.hot.corp.google.com with ESMTP id oAUIVmGL019168
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 10:31:49 -0800
Received: by pzk2 with SMTP id 2so1289746pzk.18
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 10:31:48 -0800 (PST)
In-Reply-To: <1291054477.3435.1302.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 29, 2010 at 10:14 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> I was thinking of using XPS tx_queue->cpu mapping to eventually allocate
> memory with correct NUMA affinities, for qdisc/class stuff for example.
>

An interesting idea, but the real question is can this be used for all
queue related allocations.  This includes those that drivers allocate
which are probably done in initialization.

Tom
