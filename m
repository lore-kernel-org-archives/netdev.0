From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v6 3/3] A Sample of using socket cookie and uid
 for traffic monitoring
Date: Mon, 20 Mar 2017 22:41:35 -0700
Message-ID: <20170321054134.GC64990@ast-mbp.thefacebook.com>
References: <1490069337-14076-1-git-send-email-chenbofeng.kernel@gmail.com>
 <1490069337-14076-4-git-send-email-chenbofeng.kernel@gmail.com>
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
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35246 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752189AbdCUFse (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 01:48:34 -0400
Received: by mail-pg0-f49.google.com with SMTP id t143so22829042pgb.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 22:48:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1490069337-14076-4-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 09:08:57PM -0700, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
> 
> Add a sample program to demostrate the possible usage of
> get_socket_cookie and get_socket_uid helper function. The program will
> store bytes and packets counting of in/out traffic monitored by iptables
> and store the stats in a bpf map in per socket base. The owner uid of
> the socket will be stored as part of the data entry. A shell script for
> running the program is also included.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
