From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH-next v2] net/ipv4: don't use module_init in non-modular
 gre_offload
Date: Thu, 16 Jan 2014 14:05:11 -0800
Message-ID: <1389909911.31367.425.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389802795-27442-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:65291 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbaAPWFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 17:05:16 -0500
Received: by mail-yh0-f51.google.com with SMTP id l109so1155006yhq.38
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 14:05:14 -0800 (PST)
In-Reply-To: <1389802795-27442-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-15 at 11:19 -0500, Paul Gortmaker wrote:
> Recent commit 438e38fadca2f6e57eeecc08326c8a95758594d4
> ("gre_offload: statically build GRE offloading support") added
> new module_init/module_exit calls to the gre_offload.c file.
...
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
> 
> v2: dump gre_offload_exit entirely as suggested by Eric.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
