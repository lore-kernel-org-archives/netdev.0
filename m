From: Jun Zhao <mypopydev@gmail.com>
Subject: Re: [PATCH 1/1] ipv6 : ip6mr.c : Fix can't match the IPv6
 multicast packets with input net device in netfilter FORWARD chain.
Date: Fri, 03 Aug 2012 14:10:46 +0800
Message-ID: <1343974247.3100.8.camel@barry.localdomain>
References: <1343912455-4444-1-git-send-email-mypopydev@gmail.com>
	 <20120802.162015.2106150087918919160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:58691 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165Ab2HCGKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 02:10:51 -0400
Received: by obbuo13 with SMTP id uo13so612755obb.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 23:10:50 -0700 (PDT)
In-Reply-To: <20120802.162015.2106150087918919160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-02 at 16:20 -0700, David Miller wrote:
> From: Jun Zhao <mypopydev@gmail.com>
> Date: Thu,  2 Aug 2012 21:00:55 +0800
> 
> > Current kernel change the skb's net device with output device before netfilter FORWARD chain,
> > that will lead to can't match the IPv6 multicast packets with input net device in netfilter
> > FORWARD chain.
> > 
> > the test case for reproduce this issue as follow:
> > 
> > IPv6 multicast udp stream from eth0(input device) to eth1(output device)
> 
> Your change means we now can't match on the VIF device in this situation.
> 
> I'm not applying this patch, it breaks as much as it fixes.

Hi, David:

Maybe I need to used conservative approach to fix it and don't breaks
much more, I will supply the version 2 patch for this issue.

Tks.
