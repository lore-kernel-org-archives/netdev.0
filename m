From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Thu, 31 Mar 2016 16:39:55 -0700
Message-ID: <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
	 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33985 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758113AbcCaXkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 19:40:02 -0400
Received: by mail-pa0-f45.google.com with SMTP id fe3so76596990pab.1
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 16:39:57 -0700 (PDT)
In-Reply-To: <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 01:29 +0200, Hannes Frederic Sowa wrote:
> Various fixes which were discovered by this changeset. More probably
> to come...


Really ?

Again, TCP stack locks the socket most of the time.

The fact that lockdep does not understand this is not a reason to add
this overhead.
