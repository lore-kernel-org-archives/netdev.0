From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH v1 08/15] net: sched: RCU cls_tcindex
Date: Sun, 27 Jul 2014 12:15:12 -0700
Message-ID: <CAM_iQpUJJ02hSkTfw328D8QW_4iuWcZode0JGpguecx5GUf5Jw@mail.gmail.com>
References: <20140726042439.21036.57721.stgit@nitbit.x32>
	<20140726042900.21036.45937.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:34443 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbaG0TXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2014 15:23:25 -0400
Received: by mail-oa0-f48.google.com with SMTP id m1so7678505oag.7
        for <netdev@vger.kernel.org>; Sun, 27 Jul 2014 12:23:24 -0700 (PDT)
In-Reply-To: <20140726042900.21036.45937.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2014 at 9:29 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> +
> +       if (p->perfect) {
> +               cp->perfect = kcalloc(cp->hash, sizeof(*r), GFP_KERNEL);
> +               memcpy(cp->perfect, p->perfect, sizeof(*r) * cp->hash);
> +       }

a) You forget to check the return value of kcalloc()
b) You can use kmemdup()
