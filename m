From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp_input: move out condition check from
 tcp_data_queue()
Date: Sun, 06 Aug 2017 22:04:43 -0700
Message-ID: <1502082283.25002.56.camel@edumazet-glaptop3.roam.corp.google.com>
References: <674DB789-9B28-4A9C-A0BF-D91023CB86F3@gmail.com>
         <1502039247.25002.53.camel@edumazet-glaptop3.roam.corp.google.com>
         <A64FCA3E-9A20-412D-823C-37EDA312A8C3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Ilya Matveychikov <matvejchikov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:38731 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751424AbdHGFEr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 01:04:47 -0400
Received: by mail-wr0-f193.google.com with SMTP id g32so6863482wrd.5
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 22:04:47 -0700 (PDT)
In-Reply-To: <A64FCA3E-9A20-412D-823C-37EDA312A8C3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-08-06 at 21:57 +0400, Ilya Matveychikov wrote:
> > On Aug 6, 2017, at 9:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> > On Sun, 2017-08-06 at 13:51 +0400, Ilya Matveychikov wrote:
> >> As tcp_data_queue() function is used just only twice it's better
> >> to move out the first check and wrap it with inline. It saves a
> >> single call in case the condition evaluated as true.
> >>

...

> > We wont accept such a change, because this code does not need to be
> > inlined in the callers, ( and btw inline in .c files are discouraged
> > these days )
> 
> Not sure that I understand you point. What’s the reason for that code
> not need to be inlined in the callers?

You sent a patch, you have to explain why it is needed.

Your changelog is absolutely not giving a compelling reason.

TCP stack is already complex, no need to add yet another obfuscation
unless there is a strong reason.
