From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] bpf: add show_fdinfo handler for maps
Date: Thu, 19 Nov 2015 19:19:24 +0100
Message-ID: <1447957164.2292053.444566657.27F336C7@webmail.messagingengine.com>
References: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:46930 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755266AbbKSSTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 13:19:25 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id C318C20AE4
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 13:19:24 -0500 (EST)
In-Reply-To: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015, at 11:56, Daniel Borkmann wrote:
> Add a handler for show_fdinfo() to be used by the anon-inodes
> backend for eBPF maps, and dump the map specification there. Not
> only useful for admins, but also it provides a minimal way to
> compare specs from ELF vs pinned object.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Does it make sense to include bpf_htab->count in case of a hashmap?

Thanks,
Hannes
