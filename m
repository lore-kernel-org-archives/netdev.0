From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next] documentation: Document issues with VMs and
 XPS and drivers enabling it on their own
Date: Sat, 27 Aug 2016 12:41:30 -0700
Message-ID: <CALx6S356MGsEiJkuTEfPLv=KGdfqZoz6Q2AJhPqp9yx-t2g15A@mail.gmail.com>
References: <20160825225543.BFA562900836@tardy> <CALx6S35myS9QTA7QhnDpL8ybC2c6S8LOp47iNEGS_zxXXVf4mw@mail.gmail.com>
 <20160826.213550.1069021753459989756.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rick Jones <rick.jones2@hpe.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:35617 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751194AbcH0Tlb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 15:41:31 -0400
Received: by mail-it0-f51.google.com with SMTP id x131so46446457ite.0
        for <netdev@vger.kernel.org>; Sat, 27 Aug 2016 12:41:31 -0700 (PDT)
In-Reply-To: <20160826.213550.1069021753459989756.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 9:35 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Thu, 25 Aug 2016 16:43:35 -0700
>
>> This seems like it will only confuse users even more. You've clearly
>> identified an issue, let's figure out how to fix it.
>
> I kinda feel the same way about this situation.

I'm working on XFS (as the transmit analogue to RFS). We'll track
flows enough so that we should know when it's safe to move them.

Tom
