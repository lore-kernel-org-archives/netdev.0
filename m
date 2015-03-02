From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ebpf: move CONFIG_BPF_SYSCALL-only function
 declarations
Date: Mon, 02 Mar 2015 15:09:26 -0500 (EST)
Message-ID: <20150302.150926.1234952192013427595.davem@davemloft.net>
References: <4564a0e32064e77c4a96a21909423251e251916b.1425305972.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, masami.hiramatsu.pt@hitachi.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754159AbbCBUJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 15:09:29 -0500
In-Reply-To: <4564a0e32064e77c4a96a21909423251e251916b.1425305972.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon,  2 Mar 2015 15:21:55 +0100

> Masami noted that it would be better to hide the remaining CONFIG_BPF_SYSCALL-only
> function declarations within the BPF header ifdef, w/o else path dummy alternatives
> since these functions are not supposed to have a user outside of CONFIG_BPF_SYSCALL.
> 
> Suggested-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
> Reference: http://article.gmane.org/gmane.linux.kernel.api/8658
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
