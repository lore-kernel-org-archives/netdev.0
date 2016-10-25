From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: send/sendmsg ENOMEM errors WAS(Re: [PATCH net 6/6] sctp: not
 return ENOMEM err back in sctp_packet_transmit
Date: Tue, 25 Oct 2016 07:04:02 -0400
Message-ID: <7aa1de3e-19c4-91bd-c0d6-a61f32fa6876@mojatatu.com>
References: <c15cc225-608d-5268-d179-6a997c3cad62@mojatatu.com>
 <daecd6b5-47cf-c5de-90f5-445e0038dfce@mojatatu.com>
 <CADvbK_ci-aaX6-mgXTgR0mJm9ww7+48DmXH+m5R+-0PyMDH16g@mail.gmail.com>
 <2fa21505-59c2-fb8b-6e89-11fccc953d25@mojatatu.com>
 <CADvbK_cvYhCfzuJCcoUC3+Ghv+VYLoyRGo0mt9UccjYpSBYD0g@mail.gmail.com>
 <369b7b2c-d1fb-5dd2-30b9-4f54400aa770@mojatatu.com>
 <CADvbK_eEaZBDXfY6D5dqRq3WRSgxvcHUxbq6JPnSrZ6Zpkghrw@mail.gmail.com>
 <20161025103416.GG2958@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Xin Long <lucien.xin@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Vlad Yasevich <vyasevic@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Michael Tuexen <Michael.Tuexen@lurchi.franken.de>,
        Eric Dumazet <edumazet@google.com>,
        Brenda Butler <bjb@mojatatu.com>, gabor@mojatatu.com
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36354 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965858AbcJYLEF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 07:04:05 -0400
Received: by mail-oi0-f65.google.com with SMTP id e12so6398818oib.3
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 04:04:05 -0700 (PDT)
In-Reply-To: <20161025103416.GG2958@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-25 06:34 AM, Marcelo Ricardo Leitner wrote:
> On Tue, Oct 25, 2016 at 05:05:41PM +0800, Xin Long wrote:
>>>> in case [1], user can't see the ENOMEM, ENOMEM is more like

>
> Thing is, it may lead to duplicate messages in Application layer, as the
> msg that was errored out may have been actually queued and later
> retransmitted.
>
> That's why I said the recovery steps from this depends on the
> application on top of SCTP, if it can handle such duplicate messages or
> not.

Yes, I was worried about duplicate messages.
Which is a bug on SCTP implementation on Linux, unfortunately. IOW,
transport should take care of duplicates - not the app.
i.e any app change is a workaround which will be  unnecessary in newer
kernels.

cheers,
jamal
