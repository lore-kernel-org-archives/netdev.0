From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: add show_fdinfo handler for maps
Date: Thu, 19 Nov 2015 10:32:41 -0800
Message-ID: <20151119183240.GA5993@ast-mbp.thefacebook.com>
References: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
 <1447957164.2292053.444566657.27F336C7@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35183 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757271AbbKSScr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 13:32:47 -0500
Received: by pacej9 with SMTP id ej9so88643820pac.2
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 10:32:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1447957164.2292053.444566657.27F336C7@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015 at 07:19:24PM +0100, Hannes Frederic Sowa wrote:
> On Thu, Nov 19, 2015, at 11:56, Daniel Borkmann wrote:
> > Add a handler for show_fdinfo() to be used by the anon-inodes
> > backend for eBPF maps, and dump the map specification there. Not
> > only useful for admins, but also it provides a minimal way to
> > compare specs from ELF vs pinned object.
> > 
> > Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> Does it make sense to include bpf_htab->count in case of a hashmap?

no. user space should not rely on such things. It can only be misused.
