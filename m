From: Eric Dumazet <edumazet@google.com>
Subject: Re: [Patch net-next] tcp: add a tracepoint for tcp_retransmit_skb()
Date: Tue, 10 Oct 2017 04:21:09 -0700
Message-ID: <CANn89i+vtkP+bisnTURSazuKwtjeYJjLba6wZOLg5AjsqjJPqQ@mail.gmail.com>
References: <20171010053547.21162-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:50836 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755890AbdJJLVK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 07:21:10 -0400
Received: by mail-qt0-f169.google.com with SMTP id f15so50029846qtf.7
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 04:21:10 -0700 (PDT)
In-Reply-To: <20171010053547.21162-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 9, 2017 at 10:35 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> We need a real-time notification for tcp retransmission
> for monitoring.

Hi Cong

This seems to not be well defined.

For example, why a retransmission triggered by TLP is not traced ?
