From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/2] New getsockopt option to retrieve socket
 cookie
Date: Thu, 6 Apr 2017 09:05:53 -0400
Message-ID: <20170406130552.GA58484@ast-mbp.thefacebook.com>
References: <1491444056-4312-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:34070 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753213AbdDFNF5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 09:05:57 -0400
Received: by mail-yw0-f193.google.com with SMTP id d191so2753517ywe.1
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 06:05:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1491444056-4312-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 05, 2017 at 07:00:54PM -0700, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
> 
> 
> In the current kernel socket cookie implementation, there is no simple
> and direct way to retrieve the socket cookie based on file descriptor. A
> process mat need to get it from sock fd if it want to correlate with
> sock_diag output or use a bpf map with new socket cookie function.
> 
> If userspace wants to receive the socket cookie for a given socket fd,
> it must send a SOCK_DIAG_BY_FAMILY dump request and look for the 5-tuple.
> This is slow and can be ambiguous in the case of sockets that have the
> same 5-tuple (e.g., tproxy / transparent sockets, SO_REUSEPORT sockets,
> etc.).
> 
> As shown in the example program. The xt_eBPF program is using socket cookie
> to record the network traffics statistics and with the socket cookie
> retrieved by getsockopt. The program can directly access to a specific
> socket data without scanning the whole bpf map.

Thank you for detailed description of the feature.
Both patches look good to me.
Acked-by: Alexei Starovoitov <ast@kernel.org>
