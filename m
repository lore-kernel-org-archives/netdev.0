From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf, verifier: annotate verbose printer with
 __printf
Date: Tue, 03 Nov 2015 11:36:38 -0500 (EST)
Message-ID: <20151103.113638.444736381559098660.davem@davemloft.net>
References: <148eb693cd6fe017da1c5a564d972c06cb24166b.1446546825.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755141AbbKCQgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 11:36:46 -0500
In-Reply-To: <148eb693cd6fe017da1c5a564d972c06cb24166b.1446546825.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue,  3 Nov 2015 11:39:20 +0100

> The verbose() printer dumps the verifier state to user space, so let gcc
> take care to check calls to verbose() for (future) errors. make with W=1
> correctly suggests: function might be possible candidate for 'gnu_printf'
> format attribute [-Wsuggest-attribute=format].
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
