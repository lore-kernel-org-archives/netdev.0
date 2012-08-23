From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: dev: fix the incorrect hold of net namespace's lo
 device
Date: Thu, 23 Aug 2012 05:13:09 +0200
Message-ID: <1345691589.5904.33.camel@edumazet-glaptop>
References: <1345624262-6554-1-git-send-email-gaofeng@cn.fujitsu.com>
	 <1345624786.5158.759.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:36447 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757207Ab2HWDNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 23:13:14 -0400
Received: by weyx8 with SMTP id x8so149592wey.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 20:13:12 -0700 (PDT)
In-Reply-To: <1345624786.5158.759.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 10:39 +0200, Eric Dumazet wrote:

> rcu_barrier() at this place will kill some workloads.

For example, I tested the following one :

modprobe dummy numdummies=1000
time rmmod dummy

-> 16.5 seconds instead of 0.4 second
