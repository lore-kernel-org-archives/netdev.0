From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2] bpf: grab rcu read lock for bpf_percpu_hash_update
Date: Fri, 19 Feb 2016 10:56:25 -0800
Message-ID: <20160219185624.GA94654@ast-mbp.thefacebook.com>
References: <1455907990-22250-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34718 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbcBSS4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 13:56:30 -0500
Content-Disposition: inline
In-Reply-To: <1455907990-22250-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 01:53:10PM -0500, Sasha Levin wrote:
> bpf_percpu_hash_update() expects rcu lock to be held and warns if it's not,
> which pointed out a missing rcu read lock.
> 
> Fixes: 15a07b338 ("bpf: add lookup/update support for per-cpu hash and array maps")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

thank you.
Acked-by: Alexei Starovoitov <ast@kernel.org>
