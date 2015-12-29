From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 3/3] bpf: hash: use per-bucket spinlock
Date: Tue, 29 Dec 2015 17:27:07 +0100
Message-ID: <5682B45B.40007@iogearbox.net>
References: <1451400027-28892-1-git-send-email-tom.leiming@gmail.com> <1451400027-28892-4-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59598 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbbL2Q1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 11:27:14 -0500
In-Reply-To: <1451400027-28892-4-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/29/2015 03:40 PM, Ming Lei wrote:
> Both htab_map_update_elem() and htab_map_delete_elem() can be
> called from eBPF program, and they may be in kernel hot path,
> so it isn't efficient to use a per-hashtable lock in this two
> helpers.
>
> The per-hashtable spinlock is used for protecting bucket's
> hlist, and per-bucket lock is just enough. This patch converts
> the per-hashtable lock into per-bucket spinlock, so that
> contention can be decreased a lot.
>
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>

Looks better, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
