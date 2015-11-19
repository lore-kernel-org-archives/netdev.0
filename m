From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] bpf: add show_fdinfo handler for maps
Date: Thu, 19 Nov 2015 21:12:30 +0100
Message-ID: <1447963950.3032383.444676081.5CE47461@webmail.messagingengine.com>
References: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
 <1447957164.2292053.444566657.27F336C7@webmail.messagingengine.com>
 <20151119183240.GA5993@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:59286 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161183AbbKSUMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 15:12:31 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 601DA20B4C
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 15:12:30 -0500 (EST)
In-Reply-To: <20151119183240.GA5993@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015, at 19:32, Alexei Starovoitov wrote:
> On Thu, Nov 19, 2015 at 07:19:24PM +0100, Hannes Frederic Sowa wrote:
> > On Thu, Nov 19, 2015, at 11:56, Daniel Borkmann wrote:
> > > Add a handler for show_fdinfo() to be used by the anon-inodes
> > > backend for eBPF maps, and dump the map specification there. Not
> > > only useful for admins, but also it provides a minimal way to
> > > compare specs from ELF vs pinned object.
> > > 
> > > Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> > 
> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > 
> > Does it make sense to include bpf_htab->count in case of a hashmap?
> 
> no. user space should not rely on such things. It can only be misused.

Sorry, I don't get it. How can it be misused? As an admin it would
certainly be interesting to know the pressure on the map? Do you expect
kmsg messages from the eBPF program?

Thanks,
Hannes
