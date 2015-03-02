From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] filter: refactor common filter attach code
 into __sk_attach_prog
Date: Mon, 02 Mar 2015 14:54:11 -0500 (EST)
Message-ID: <20150302.145411.1714833785061319525.davem@davemloft.net>
References: <8c751ae5e391a3b2dd7a541ad89b3255d2a1f19d.1425295277.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753870AbbCBTyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 14:54:13 -0500
In-Reply-To: <8c751ae5e391a3b2dd7a541ad89b3255d2a1f19d.1425295277.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon,  2 Mar 2015 12:25:51 +0100

> Both sk_attach_filter() and sk_attach_bpf() are setting up sk_filter,
> charging skmem and attaching it to the socket after we got the eBPF
> prog up and ready. Lets refactor that into a common helper.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
