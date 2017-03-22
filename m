From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next v7 3/3] A Sample of using socket cookie and uid
 for traffic monitoring
Date: Wed, 22 Mar 2017 11:13:07 +0000
Message-ID: <CAF=yD-+zAWzM1DcQm1qc9paikHJRJB+oK7_w=xiexw9zmXNw5w@mail.gmail.com>
References: <1490133934-7055-1-git-send-email-chenbofeng.kernel@gmail.com> <1490133934-7055-4-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:36112 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933600AbdCVLNv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 07:13:51 -0400
Received: by mail-qt0-f181.google.com with SMTP id r45so150540688qte.3
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 04:13:49 -0700 (PDT)
In-Reply-To: <1490133934-7055-4-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 21, 2017 at 10:05 PM, Chenbo Feng
<chenbofeng.kernel@gmail.com> wrote:
> From: Chenbo Feng <fengc@google.com>
>
> Add a sample program to demostrate the possible usage of
> get_socket_cookie and get_socket_uid helper function. The program will
> store bytes and packets counting of in/out traffic monitored by iptables
> and store the stats in a bpf map in per socket base. The owner uid of
> the socket will be stored as part of the data entry. A shell script for
> running the program is also included.
>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Chenbo Feng <fengc@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>
