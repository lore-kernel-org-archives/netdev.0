From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sock_diag: request _diag module only when the
 family or proto has been registered
Date: Tue, 17 Oct 2017 04:35:15 -0700
Message-ID: <1508240115.31614.94.camel@edumazet-glaptop3.roam.corp.google.com>
References: <69c0824505548e733f2f7be3ff288f2c4e461afa.1508217236.git.lucien.xin@gmail.com>
         <1508238974.31614.91.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:56735 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756912AbdJQLfS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 07:35:18 -0400
Received: by mail-it0-f68.google.com with SMTP id r127so1953246itb.5
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 04:35:17 -0700 (PDT)
In-Reply-To: <1508238974.31614.91.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-17 at 04:16 -0700, Eric Dumazet wrote:
> On Tue, 2017-10-17 at 13:13 +0800, Xin Long wrote:
> 
> > +bool sock_is_registered(int family)
> > +{
> > +	return family < NPROTO && rcu_access_pointer(net_families[family]);
> > +}
> 
> EXPORT_SYMBOL() ?

I take this back. Since there is one single user in vmlinux, no need yet

Reviewed-by: Eric Dumazet <edumazet@google.com>
