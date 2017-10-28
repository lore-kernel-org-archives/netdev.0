From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] samples/bpf: adjust rlimit RLIMIT_MEMLOCK for
 xdp1
Date: Fri, 27 Oct 2017 18:59:15 -0700
Message-ID: <20171028015913.ffhi7xub45sxbevy@ast-mbp>
References: <1509145950-5840-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org
To: Tushar Dave <tushar.n.dave@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:51078 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751025AbdJ1B7S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 21:59:18 -0400
Received: by mail-pf0-f193.google.com with SMTP id b6so6131786pfh.7
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 18:59:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1509145950-5840-1-git-send-email-tushar.n.dave@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 04:12:30PM -0700, Tushar Dave wrote:
> Default rlimit RLIMIT_MEMLOCK is 64KB, causes bpf map failure.
> e.g.
> [root@lab bpf]#./xdp1 -N $(</sys/class/net/eth2/ifindex)
> failed to create a map: 1 Operation not permitted
> 
> Fix it.
> 
> Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
