From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: rather use get_random_int for randomizations
Date: Fri, 20 May 2016 11:24:06 -0700 (PDT)
Message-ID: <20160520.112406.286390667027285394.davem@davemloft.net>
References: <24461974e8402395c12b3e36b9ac7935b88ef1c2.1463572456.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbcETSYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 14:24:07 -0400
In-Reply-To: <24461974e8402395c12b3e36b9ac7935b88ef1c2.1463572456.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 18 May 2016 14:14:28 +0200

> Start address randomization and blinding in BPF currently use
> prandom_u32(). prandom_u32() values are not exposed to unpriviledged
> user space to my knowledge, but given other kernel facilities such as
> ASLR, stack canaries, etc make use of stronger get_random_int(), we
> better make use of it here as well given blinding requests successively
> new random values. get_random_int() has minimal entropy pool depletion,
> is not cryptographically secure, but doesn't need to be for our use
> cases here.
> 
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Ok, applied, thanks Daniel.
