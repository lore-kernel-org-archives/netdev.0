From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH net-next 1/1] Introduce skbmod action
Date: Tue, 12 Jul 2016 10:10:15 -0700
Message-ID: <CAM_iQpWNxZjWM-f_siOuXf+w_mgxKay9S8kAmUTD+8YLXp2S+g@mail.gmail.com>
References: <1468239164-17898-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	nikolay@cumulusnetworks.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32962 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbcGLRKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 13:10:45 -0400
Received: by mail-io0-f194.google.com with SMTP id y195so1429735iod.0
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 10:10:40 -0700 (PDT)
In-Reply-To: <1468239164-17898-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 5:12 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> This action is intended to be an upgrade from a usability perspective
> from pedit. Compare this:
>

Definitely agree we need a more user-friendly interface.

>
> pedit is a good starting point - but once you start going to a large
> number of policies then from a programmability, ops and usability point
> of view you need something with more succint params.
>

But it is still unclear why we can't just build something on top of
pedit? Since pedit accepts keys like u32, user-space is free to
introduce any wrapper on top of it.

It should not be a problem for libnl3 to build anything on top too.
