From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] samples/bpf: adjust rlimit RLIMIT_MEMLOCK for
 xdp_redirect_map
Date: Fri, 27 Oct 2017 18:59:36 -0700
Message-ID: <20171028015934.3aajugi7nqtogwm3@ast-mbp>
References: <1509150502-6632-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org
To: Tushar Dave <tushar.n.dave@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:44546 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751025AbdJ1B7i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 21:59:38 -0400
Received: by mail-pg0-f65.google.com with SMTP id j3so6551150pga.1
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 18:59:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1509150502-6632-1-git-send-email-tushar.n.dave@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 05:28:22PM -0700, Tushar Dave wrote:
> Default rlimit RLIMIT_MEMLOCK is 64KB, causes bpf map failure.
> e.g.
> [root@labbpf]# ./xdp_redirect_map $(</sys/class/net/eth2/ifindex) \
> > $(</sys/class/net/eth3/ifindex)
> failed to create a map: 1 Operation not permitted
> 
> The failure is 100% when multiple xdp programs are running. Fix it.
> 
> Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
