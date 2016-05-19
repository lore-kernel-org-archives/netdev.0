From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: remove busylock
Date: Thu, 19 May 2016 11:44:10 -0700
Message-ID: <1463683450.18194.220.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160519.111208.1949769629804288508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aduyck@mirantis.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33853 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932811AbcESSoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 14:44:13 -0400
Received: by mail-pf0-f193.google.com with SMTP id 145so8940631pfz.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 11:44:13 -0700 (PDT)
In-Reply-To: <20160519.111208.1949769629804288508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-19 at 11:12 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 19 May 2016 10:08:36 -0700
> 
> > busylock was added at the time we had expensive ticket spinlocks
> > 
> > (commit 79640a4ca6955e3ebdb7038508fa7a0cd7fa5527 ("net: add additional
> > lock to qdisc to increase throughput")
> > 
> > Now kernel spinlocks are MCS, this busylock things is no longer
> > relevant. It is slowing down things a bit.
>  ...
> > That would be a 8 % increase.
> 
> Presumably only for x86-64 and other platforms that actually are using
> the ticket spinlocks.
> 
> For others it would be a regression.

Ticket spinlocks are actually gone, these are now MCS.

But yes, point taken ;)
