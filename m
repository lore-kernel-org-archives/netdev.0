From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net, sched: add clsact qdisc
Date: Tue, 5 Jan 2016 18:40:42 -0800
Message-ID: <CAM_iQpWzQQQaQYZZPg3yvnkm_KZWD26jm_Xo1KN6ugjKAJLixA@mail.gmail.com>
References: <d091709bf1a93c65cdadc9a990c9065e065840b8.1452041153.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	john fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:33725 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbcAFCkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 21:40:42 -0500
Received: by mail-yk0-f170.google.com with SMTP id k129so280315681yke.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 18:40:42 -0800 (PST)
In-Reply-To: <d091709bf1a93c65cdadc9a990c9065e065840b8.1452041153.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 5, 2016 at 5:00 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index c20b814..752c0d2 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1739,7 +1739,9 @@ struct net_device {
>  #ifdef CONFIG_XPS
>         struct xps_dev_maps __rcu *xps_maps;
>  #endif
> -
> +#ifdef CONFIG_NET_CLS_ACT
> +       struct tcf_proto __rcu  *egress_cl_list;
> +#endif


Next time you add a qdisc will you need another pointer in netdevice? ;)
