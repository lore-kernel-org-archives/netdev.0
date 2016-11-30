From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf, xdp: allow to pass flags to
 dev_change_xdp_fd
Date: Wed, 30 Nov 2016 10:27:42 -0500 (EST)
Message-ID: <20161130.102742.1086706845439281662.davem@davemloft.net>
References: <cd0871f11c476f8d7fee1cb356940a13cf7d4807.1480370617.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33362 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753980AbcK3P1n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:27:43 -0500
In-Reply-To: <cd0871f11c476f8d7fee1cb356940a13cf7d4807.1480370617.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 28 Nov 2016 23:16:54 +0100

> Add an IFLA_XDP_FLAGS attribute that can be passed for setting up
> XDP along with IFLA_XDP_FD, which eventually allows user space to
> implement typical add/replace/delete logic for programs. Right now,
> calling into dev_change_xdp_fd() will always replace previous programs.
> 
> When passed XDP_FLAGS_UPDATE_IF_NOEXIST, we can handle this more
> graceful when requested by returning -EBUSY in case we try to
> attach a new program, but we find that another one is already
> attached. This will be used by upcoming front-end for iproute2 as
> well.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks Daniel.
