From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: add get_next_key callback to LPM map
Date: Sun, 05 Mar 2017 10:44:13 -0800 (PST)
Message-ID: <20170305.104413.1645369685777679734.davem@davemloft.net>
References: <1488735668-2296008-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, daniel@zonque.org, dvyukov@google.com,
        netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58806 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752186AbdCESy2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 13:54:28 -0500
In-Reply-To: <1488735668-2296008-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Sun, 5 Mar 2017 09:41:08 -0800

> map_get_next_key callback is mandatory. Supply dummy handler.
> 
> Fixes: b95a5c4db09b ("bpf: add a longest prefix match trie map implementation")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Wouldn't it be more appropriate to provide a proper DFS ordered
traversal rather than return an error code?
