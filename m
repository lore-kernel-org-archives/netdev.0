From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] tcp: add a tracepoint for tcp_retransmit_skb()
Date: Tue, 10 Oct 2017 10:16:21 -0700
Message-ID: <CAM_iQpWYgNrSmZYMj-jBSqDud0x=1d+8BTjECD+apBY-91FgLw@mail.gmail.com>
References: <20171010053547.21162-1-xiyou.wangcong@gmail.com> <CANn89i+vtkP+bisnTURSazuKwtjeYJjLba6wZOLg5AjsqjJPqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33707 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755473AbdJJRQm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 13:16:42 -0400
Received: by mail-pf0-f196.google.com with SMTP id m28so36970493pfi.0
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 10:16:42 -0700 (PDT)
In-Reply-To: <CANn89i+vtkP+bisnTURSazuKwtjeYJjLba6wZOLg5AjsqjJPqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 4:21 AM, Eric Dumazet <edumazet@google.com> wrote:
> On Mon, Oct 9, 2017 at 10:35 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> We need a real-time notification for tcp retransmission
>> for monitoring.
>
> Hi Cong
>
> This seems to not be well defined.
>
> For example, why a retransmission triggered by TLP is not traced ?

Oh, it should, seems I should just put the trace in __tcp_retransmit_skb()
instead...

I will update the patch after waiting for other feedbacks.

Thanks.
