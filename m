From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 2/3] net: Cap number of elements for sendmmsg
Date: Fri, 05 Aug 2011 14:50:06 +0900
Message-ID: <201108050550.p755o6v8049250@www262.sakura.ne.jp>
References: <20110805000737.743684961@samba.org> <20110805000822.327910762@samba.org> <201108050429.p754TTBa030939@www262.sakura.ne.jp> <20110805144619.729c631a@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	eparis@parisplace.org, casey@schaufler-ca.com, mjt@tls.msk.ru
To: anton@samba.org, acme@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:65169 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754873Ab1HEFuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 01:50:08 -0400
In-Reply-To: <20110805144619.729c631a@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Blanchard wrote:
> > Apart from the upper limit for vlen argument of sendmmsg()/recvmmsg(),
> > we need to deal with stall problem (described below).
> 
> Capping vlen at 1024 should prevent that. Your patch does a signed
> comparison which just reduces the maximum value by 1 bit doesn't it?

Just for avoiding returning IS_ERR_VALUE() value upon success.

> Keep in mind each element could have up to 1024 iovec entries at worst
> case, so I think 1024 is a sane upper max.

OK. Please take Anton's version.

Arnaldo, please consider copying this change to recvmmsg() too.
