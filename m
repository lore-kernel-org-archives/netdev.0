From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] rhashtable: Allow other tasks to be scheduled
 in large lookup loops
Date: Fri, 17 Jul 2015 10:28:33 +0200
Message-ID: <1437121713.1026.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <2dcec22264c46d248e4f56ac5dfd6a8d321b162f.1437120351.git.tgraf@suug.ch>
	 <1437121457.1026.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, mroos@linux.ee,
	herbert@gondor.apana.org.au
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33427 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbbGQI2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 04:28:38 -0400
Received: by widic2 with SMTP id ic2so33487283wid.0
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 01:28:37 -0700 (PDT)
In-Reply-To: <1437121457.1026.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-17 at 10:24 +0200, Eric Dumazet wrote:

> Please simply use cond_resched() without counting and magic value.

Also use cond_resched() in insert and delete phases ?
