From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v4 1/3] bpf: add a longest prefix match trie map
 implementation
Date: Sun, 22 Jan 2017 14:57:01 -0800
Message-ID: <20170122225659.GB73160@ast-mbp.thefacebook.com>
References: <20170121162613.4159-1-daniel@zonque.org>
 <20170121162613.4159-2-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@fb.com, dh.herrmann@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36076 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750704AbdAVW5G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 17:57:06 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so11993312pgf.3
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 14:57:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170121162613.4159-2-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 21, 2017 at 05:26:11PM +0100, Daniel Mack wrote:
> This trie implements a longest prefix match algorithm that can be used
> to match IP addresses to a stored set of ranges.
> 
> Internally, data is stored in an unbalanced trie of nodes that has a
> maximum height of n, where n is the prefixlen the trie was created
> with.
> 
> Tries may be created with prefix lengths that are multiples of 8, in
> the range from 8 to 2048. The key used for lookup and update operations
> is a struct bpf_lpm_trie_key, and the value is a uint64_t.
> 
> The code carries more information about the internal implementation.
> 
> Signed-off-by: Daniel Mack <daniel@zonque.org>
> Reviewed-by: David Herrmann <dh.herrmann@gmail.com>

Looks great to me.
Acked-by: Alexei Starovoitov <ast@kernel.org>
