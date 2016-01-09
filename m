From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: cleanup bpf_prog_run_{save,clear}_cb
 helpers
Date: Fri, 08 Jan 2016 21:41:05 -0500 (EST)
Message-ID: <20160108.214105.1071742028525022329.davem@davemloft.net>
References: <aaa1eb34322115d06f15946989f4ebd3e399a56e.1452115518.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213AbcAIClJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 21:41:09 -0500
In-Reply-To: <aaa1eb34322115d06f15946989f4ebd3e399a56e.1452115518.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed,  6 Jan 2016 22:32:16 +0100

> Move the details behind the cb[] access into a small helper to decouple
> and make them generic for bpf_prog_run_save_cb()/bpf_prog_run_clear_cb()
> that was introduced via commit ff936a04e5f2 ("bpf: fix cb access in socket
> filter programs"). Also add a comment to better clarify what is done in
> bpf_skb_cb().
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
