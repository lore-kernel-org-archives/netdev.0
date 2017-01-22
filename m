From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v4 2/3] bpf: Add tests for the lpm trie map
Date: Sun, 22 Jan 2017 14:58:53 -0800
Message-ID: <20170122225851.GC73160@ast-mbp.thefacebook.com>
References: <20170121162613.4159-1-daniel@zonque.org>
 <20170121162613.4159-3-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@fb.com, dh.herrmann@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34048 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750704AbdAVW66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 17:58:58 -0500
Received: by mail-pg0-f66.google.com with SMTP id t6so12002607pgt.1
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 14:58:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170121162613.4159-3-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 21, 2017 at 05:26:12PM +0100, Daniel Mack wrote:
> From: David Herrmann <dh.herrmann@gmail.com>
> 
> The first part of this program runs randomized tests against the
> lpm-bpf-map. It implements a "Trivial Longest Prefix Match" (tlpm)
> based on simple, linear, single linked lists. The implementation
> should be pretty straightforward.
> 
> Based on tlpm, this inserts randomized data into bpf-lpm-maps and
> verifies the trie-based bpf-map implementation behaves the same way
> as tlpm.
> 
> The second part uses 'real world' IPv4 and IPv6 addresses and tests
> the trie with those.
> 
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
> Signed-off-by: Daniel Mack <daniel@zonque.org>

Acked-by: Alexei Starovoitov <ast@kernel.org>
