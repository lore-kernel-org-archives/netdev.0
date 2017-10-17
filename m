From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sock_diag: request _diag module only when the
 family or proto has been registered
Date: Tue, 17 Oct 2017 04:16:14 -0700
Message-ID: <1508238974.31614.91.camel@edumazet-glaptop3.roam.corp.google.com>
References: <69c0824505548e733f2f7be3ff288f2c4e461afa.1508217236.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:48814 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755416AbdJQLQR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 07:16:17 -0400
Received: by mail-pg0-f66.google.com with SMTP id v78so1154572pgb.5
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 04:16:17 -0700 (PDT)
In-Reply-To: <69c0824505548e733f2f7be3ff288f2c4e461afa.1508217236.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-17 at 13:13 +0800, Xin Long wrote:

> +bool sock_is_registered(int family)
> +{
> +	return family < NPROTO && rcu_access_pointer(net_families[family]);
> +}

EXPORT_SYMBOL() ?
