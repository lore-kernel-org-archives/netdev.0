From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net, cls: allow for deleting all filters for
 given parent
Date: Mon, 6 Jun 2016 10:12:46 -0700
Message-ID: <CAM_iQpWDc1JAa9MhcSAOdJVVRoG52Z+p47CD-rd81LzN28zk1A@mail.gmail.com>
References: <cd8455dfef0cccec5ef0a1ca2d1f678e9397d66e.1465056745.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:35935 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbcFFRNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 13:13:08 -0400
Received: by mail-yw0-f177.google.com with SMTP id x189so146217877ywe.3
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 10:13:06 -0700 (PDT)
In-Reply-To: <cd8455dfef0cccec5ef0a1ca2d1f678e9397d66e.1465056745.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 4, 2016 at 9:24 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> +       if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
> +               tcf_destroy_chain(chain);
> +               err = 0;
> +               goto errout;
> +       }

We need to notify users we removed which filters, right?
