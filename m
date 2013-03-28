From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] core: fix the use of this_cpu_ptr
Date: Thu, 28 Mar 2013 08:36:16 -0700
Message-ID: <1364484976.15753.45.camel@edumazet-glaptop>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com>
	 <1364475933.15753.36.camel@edumazet-glaptop>
	 <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, Shan Wei <davidshan@tencent.com>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:53005 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756440Ab3C1PgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 11:36:20 -0400
Received: by mail-ob0-f178.google.com with SMTP id wd20so9474089obb.9
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 08:36:20 -0700 (PDT)
In-Reply-To: <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-28 at 14:38 +0000, Christoph Lameter wrote:
> On Thu, 28 Mar 2013, Eric Dumazet wrote:

> 
> > Christoph, could this kind of error be detected by the compiler or
> > sparse ?
> 
> The per cpu variables are marked with __percpu. This should be detected by
> sparse.

make C=2 net/core/flow.o

  CHECK   net/core/flow.c

No warning.
