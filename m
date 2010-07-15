From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH RFC] act_cpu: packet distributing
Date: Thu, 15 Jul 2010 08:48:59 -0400
Message-ID: <1279198139.4510.710.camel@bigi>
References: <1279077475-2956-1-git-send-email-xiaosuo@gmail.com>
	 <1279078875.2444.103.camel@edumazet-laptop>
	 <AANLkTimPmXWyAspJqnya7aM_vDRNzDdJJf2bl7CYrAXN@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:41015 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933137Ab0GOMtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 08:49:06 -0400
Received: by gwj18 with SMTP id 18so399069gwj.19
        for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 05:49:03 -0700 (PDT)
In-Reply-To: <AANLkTimPmXWyAspJqnya7aM_vDRNzDdJJf2bl7CYrAXN@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-07-14 at 12:17 +0800, Changli Gao wrote:

> Thanks, I'll try. It is a write critical section, and for me it is
> difficult to convert this lock to RCU. Could you show me some
> examples?

RCU maybe a little trickier here Eric. Actions could be shared i.e. 
example, it is possible to have a policer action restricting rates for a
group of flows  across multiple netdevices etc. Since action stats get
written to by different CPUs concurrently. It could be probably done if
one was to implement per-cpu stats which get summed-up when user space
asks.

cheers,
jamal

