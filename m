From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: map_get_next_key to return first key on
 NULL
Date: Tue, 25 Apr 2017 11:57:57 -0400 (EDT)
Message-ID: <20170425.115757.702639212104220856.davem@davemloft.net>
References: <20170425020037.1114047-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, qinteng@fb.com, netdev@vger.kernel.org,
        kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41184 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970916AbdDYP6E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:58:04 -0400
In-Reply-To: <20170425020037.1114047-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Mon, 24 Apr 2017 19:00:37 -0700

> From: Teng Qin <qinteng@fb.com>
> 
> When iterating through a map, we need to find a key that does not exist
> in the map so map_get_next_key will give us the first key of the map.
> This often requires a lot of guessing in production systems.
> 
> This patch makes map_get_next_key return the first key when the key
> pointer in the parameter is NULL.
> 
> Signed-off-by: Teng Qin <qinteng@fb.com>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Alexei.
