From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2] bpf: grab rcu read lock for bpf_percpu_hash_update
Date: Fri, 19 Feb 2016 20:02:08 +0100
Message-ID: <56C766B0.1070607@iogearbox.net>
References: <1455907990-22250-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: Sasha Levin <sasha.levin@oracle.com>, ast@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47003 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422838AbcBSTCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 14:02:16 -0500
In-Reply-To: <1455907990-22250-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/19/2016 07:53 PM, Sasha Levin wrote:
> bpf_percpu_hash_update() expects rcu lock to be held and warns if it's not,
> which pointed out a missing rcu read lock.
>
> Fixes: 15a07b338 ("bpf: add lookup/update support for per-cpu hash and array maps")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

LGTM, patch is against net-next tree.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
