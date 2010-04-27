From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Tue, 27 Apr 2010 10:31:08 -0700
Message-ID: <g2k65634d661004271031r2eb2000bxc30013009509c410@mail.gmail.com>
References: <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>
	 <20100426.110432.104061817.davem@davemloft.net>
	 <4BD6E887.3000804@athenacr.com>
	 <20100427.095108.68126984.davem@davemloft.net>
	 <1272388439.2295.369.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, bmb@athenacr.com,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:25412 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516Ab0D0RbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 13:31:14 -0400
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o3RHVCf1015693
	for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 10:31:13 -0700
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by kpbe18.cbf.corp.google.com with ESMTP id o3RHV0ff015493
	for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 10:31:11 -0700
Received: by pwj1 with SMTP id 1so8135106pwj.9
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 10:31:11 -0700 (PDT)
In-Reply-To: <1272388439.2295.369.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So we have a BIG problem :
>
> All cpus are fighting to get the socket lock,
> and very litle progress is done.
>
> Note this problem has nothing to do with RPS, we could have
> it with multiqueue as well.
>

This is the problem that we are addressing with so_reuseport!

> Oh well...
>
>
>
>
