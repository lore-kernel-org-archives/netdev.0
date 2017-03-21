From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v6 2/3] Add a eBPF helper function to retrieve
 socket uid
Date: Mon, 20 Mar 2017 22:40:59 -0700
Message-ID: <20170321054058.GB64990@ast-mbp.thefacebook.com>
References: <1490069337-14076-1-git-send-email-chenbofeng.kernel@gmail.com>
 <1490069337-14076-3-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35529 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756303AbdCUFlG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 01:41:06 -0400
Received: by mail-pg0-f42.google.com with SMTP id t143so22743726pgb.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 22:41:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1490069337-14076-3-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 09:08:56PM -0700, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
> 
> Returns the owner uid of the socket inside a sk_buff. This is useful to
> perform per-UID accounting of network traffic or per-UID packet
> filtering. The socket need to be a fullsock otherwise overflowuid is
> returned.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
