From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: make error reporting in
 bpf_warn_invalid_xdp_action more clear
Date: Fri, 08 Sep 2017 21:13:35 -0700 (PDT)
Message-ID: <20170908.211335.1475899596165757096.davem@davemloft.net>
References: <a89dbb43f7196f6ba8c5fd1f07c7e4bcc97726c3.1504913751.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, john.fastabend@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43284 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750899AbdIIENf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 9 Sep 2017 00:13:35 -0400
In-Reply-To: <a89dbb43f7196f6ba8c5fd1f07c7e4bcc97726c3.1504913751.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat,  9 Sep 2017 01:40:35 +0200

> Differ between illegal XDP action code and just driver
> unsupported one to provide better feedback when we throw
> a one-time warning here. Reason is that with 814abfabef3c
> ("xdp: add bpf_redirect helper function") not all drivers
> support the new XDP return code yet and thus they will
> fall into their 'default' case when checking for return
> codes after program return, which then triggers a
> bpf_warn_invalid_xdp_action() stating that the return
> code is illegal, but from XDP perspective it's not.
> 
> I decided not to place something like a XDP_ACT_MAX define
> into uapi i) given we don't have this either for all other
> program types, ii) future action codes could have further
> encoding there, which would render such define unsuitable
> and we wouldn't be able to rip it out again, and iii) we
> rarely add new action codes.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied.
