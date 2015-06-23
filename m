From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lib: test_bpf: purge CPP register redefinitions
Date: Tue, 23 Jun 2015 06:47:56 -0700 (PDT)
Message-ID: <20150623.064756.774554173201417256.davem@davemloft.net>
References: <5587B0C7.8090507@nod.at>
	<5587B4FB.3040609@nod.at>
	<87egl3lusf.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard@nod.at, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	daniel@iogearbox.net
To: nicstange@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229AbbFWNgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:36:09 -0400
In-Reply-To: <87egl3lusf.fsf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolai Stange <nicstange@gmail.com>
Date: Mon, 22 Jun 2015 15:47:12 +0200

> Richard Weinberger <richard@nod.at> writes:
>> While riding the bus to my office I've materialized that idea.
>> Nicolai, can you please give the attached patch a try?
> W/o my test_bpf patch applied, w/ your patch applied:
>  - linux mainline: um compiles
>  - linux-next: um compiles up to this mfd/syscon issue communicated to
>                you in sidechannel
> 
> In particular, your patch fixes, next to [0], the issue addressed by my
> patch.
> 
> -> My 1K line regexp replace patch reduces to a debatable naming style
>    patch. Drop it, sorry for the noise.
> 
> [0] http://lkml.kernel.org/r/1420386535-22530-1-git-send-email-richard@nod.at

Ok, I'll revert this then.
