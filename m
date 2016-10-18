From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] sched, cls: don't dump kernel addr into tc monitors
 on delete event
Date: Tue, 18 Oct 2016 16:14:09 -0700
Message-ID: <CAM_iQpW4RdVo72=nQVaehkUCA98yq8+PyFQUTxis-Bx7XgVkFw@mail.gmail.com>
References: <f7e28cd6ec298a90dc33fcc85e7361eb92025690.1476821268.git.daniel@iogearbox.net>
 <c02ce4f1-ba99-f54c-d35d-ca81cc771c8a@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35190 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751635AbcJRXOa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 19:14:30 -0400
Received: by mail-io0-f195.google.com with SMTP id p26so680894ioo.2
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 16:14:30 -0700 (PDT)
In-Reply-To: <c02ce4f1-ba99-f54c-d35d-ca81cc771c8a@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 18, 2016 at 2:21 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> I was sitting on this patch I was going to send ;->
> Does this resolve it?

Your patch makes more sense to me. Maybe we can remove the
event != RTM_DELTFILTER special case too?
