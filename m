From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/5] net_sched: Fail if missing mandatory action operation
 methods
Date: Wed, 04 Dec 2013 12:21:57 -0500
Message-ID: <529F64B5.1030304@mojatatu.com>
References: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>	 <1386167216-30281-2-git-send-email-jhs@mojatatu.com> <1386176630.30495.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com, ebiederm@xmission.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:65281 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932708Ab3LDRWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 12:22:03 -0500
Received: by mail-ie0-f180.google.com with SMTP id tp5so26056294ieb.25
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 09:22:02 -0800 (PST)
In-Reply-To: <1386176630.30495.110.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/13 12:03, Eric Dumazet wrote:

> Could we remove all these tests on a->ops being NULL or not ?
>

Yes, i think those should go away as well.
I will wait for Dave to swallow these other patches then send one that 
gets rid of those.

cheers,
jamal

> IMHO a->ops cannot be NULL. If NULL, just crash by NULL deref.
>
>
>
>
