From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: More painful merges...
Date: Mon, 30 Oct 2017 08:58:25 -0700
Message-ID: <CAM_iQpUTauPL7Z_s-0kbp+nbg17fniMBhOyQ4tDVVmC=qFFy=g@mail.gmail.com>
References: <20171030.211551.790664985307439262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:50016 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932189AbdJ3P6q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 11:58:46 -0400
Received: by mail-pg0-f49.google.com with SMTP id g6so11981856pgn.6
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 08:58:46 -0700 (PDT)
In-Reply-To: <20171030.211551.790664985307439262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 5:15 AM, David Miller <davem@davemloft.net> wrote:
>
> BPF and tc action bug fixes in 'net' caused some extremely
> painful merges with 'net-next'.
>
> Could the interested parties please take a look at 'net-next'
> and send me any necessary fixes, as I did the best that I
> could.
>

The tcf_block_put_ext() part looks good to me. I will run
some tests to make sure.

Thanks for sorting them!
