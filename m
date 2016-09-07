From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH v4 2/6] cgroup: add support for eBPF programs
Date: Wed, 7 Sep 2016 07:58:19 +0300
Message-ID: <CAKoUAr=M6Mmqmrz=uRh6SEUXMki4m0yR+cGNZJUNe3pGk6NhNw@mail.gmail.com>
References: <1473169568-30525-1-git-send-email-daniel@zonque.org> <1473169568-30525-3-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        David Miller <davem@davemloft.net>, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com,
        Netdev <netdev@vger.kernel.org>,
        Sargun Dhillon <sargun@sargun.me>, cgroups@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:33293 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751020AbcIGE6W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 00:58:22 -0400
In-Reply-To: <1473169568-30525-3-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


+ * __cgroup_bpf_update() - Update the pinned program of a cgroup, and
+ *                         propagate the change to descendants
+ * @cgrp: The cgroup which descendants to traverse

Missing here is @parent

+ * @prog: A new program to pin
+ * @type: Type of pinning operation (ingress/egress)

...

> +void __cgroup_bpf_update(struct cgroup *cgrp,
> +                        struct cgroup *parent,
> +                        struct bpf_prog *prog,
> +                        enum bpf_attach_type type)
> +{

Regards,
Rami Rosen
