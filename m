From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] dccp/tcp: fix ireq->opt races
Date: Tue, 17 Oct 2017 12:53:21 -0700
Message-ID: <1508270001.31614.115.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1508269526.31614.113.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508269854.31614.114.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:44141 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752518AbdJQTxX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 15:53:23 -0400
Received: by mail-it0-f43.google.com with SMTP id n195so6483774itg.1
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 12:53:23 -0700 (PDT)
In-Reply-To: <1508269854.31614.114.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-17 at 12:50 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller found another bug in DCCP/TCP stacks [1]
> 
> For the reasons explained in commit ce1050089c96 ("tcp/dccp: fix
> ireq->pktopts race"), we need to make sure we do not access
> ireq->opt unless we own the request sock.


Arg, I will send a v2 without the silly lines that confuse patchwork.
