From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: sched: Make netns available for ematch
 extensions
Date: Wed, 11 Sep 2013 07:32:58 -0700
Message-ID: <1378909978.21474.3.camel@edumazet-glaptop>
References: <1378905614-29691-1-git-send-email-kadlec@blackhole.kfki.hu>
	 <1378905614-29691-2-git-send-email-kadlec@blackhole.kfki.hu>
	 <1378909915.21474.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"V. Lavrov" <lve@guap.ru>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:59807 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979Ab3IKOdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 10:33:00 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb10so9366545pad.37
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 07:33:00 -0700 (PDT)
In-Reply-To: <1378909915.21474.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-11 at 07:31 -0700, Eric Dumazet wrote:

> 
> Note that qdisc_dev(tp->q) should give you the pointer to device
> 
> Then ->nd_net gives you the struct net pointer.
> 
> On management path, this should be enough ;)

(A device can be moved from net xxxx to net yyyy)
