From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v4 3/3] A Sample of using socket cookie and uid
 for traffic monitoring
Date: Mon, 20 Mar 2017 08:56:59 -0700
Message-ID: <20170320155657.GD80094@ast-mbp.thefacebook.com>
References: <1489968524-2495-1-git-send-email-chenbofeng.kernel@gmail.com>
 <1489968524-2495-4-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34650 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751586AbdCTP5J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 11:57:09 -0400
Received: by mail-pf0-f195.google.com with SMTP id o126so17930271pfb.1
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 08:57:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1489968524-2495-4-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 19, 2017 at 05:08:44PM -0700, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
> 
> Add a sample program to demostrate the possible usage of
> get_socket_cookie and get_socket_uid helper function. The program will
> store bytes and packets counting of in/out traffic monitored by iptables
> and store the stats in a bpf map in per socket base. The owner uid of
> the socket will be stored as part of the data entry. A shell script for
> running the program is also included.
> 
> Signed-off-by: Chenbo Feng <chenbofeng.kernel@gmail.com>
> ---
>  samples/bpf/cookie_uid_helper_example.c      | 229 +++++++++++++++++++++++++++
>  samples/bpf/libbpf.h                         |  10 ++
>  samples/bpf/run_cookie_uid_helper_example.sh |  14 ++

Makefile update missing?

> + * Compile:
> + * gcc -I ../../usr/include -I ../../tools/lib -I ../../tools/include \
> + * -I ./ -Wall cookie_uid_helper_example.c ../../tools/lib/bpf/bpf.c -o \
> + * perSocketStats_example

this can be part of Makefile and please drop CamelStyle.
