From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] BPF/random32 updates
Date: Thu, 08 Oct 2015 05:27:18 -0700 (PDT)
Message-ID: <20151008.052718.857300198002962191.davem@davemloft.net>
References: <cover.1444258405.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, ast@plumgrid.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753102AbbJHMLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 08:11:32 -0400
In-Reply-To: <cover.1444258405.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu,  8 Oct 2015 01:20:34 +0200

> BPF update to split the prandom state apart, and to move the
> *once helpers to the core. For details, please see individual
> patches. Given the changes and since it's in the tree for
> quite some time, net-next is a better choice in our opinion.
> 
> v1 -> v2:
>  - Make DO_ONCE() type-safe, remove the kvec helper. Credits
>    go to Alexei Starovoitov for the __VA_ARGS__ hint, thanks!
>  - Add a comment to the DO_ONCE() helper as suggested by Alexei.
>  - Rework prandom_init_once() helper to the new API.
>  - Keep Alexei's Acked-by on the last patch.

Series applied, thanks everyone.
