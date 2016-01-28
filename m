From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: [PATCH V2] netfilter: h323: avoid potential attack
Date: Thu, 28 Jan 2016 06:00:50 -0800
Message-ID: <1453989650.7627.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453971597-4811-1-git-send-email-zhouzhouyi@gmail.com>
	 <1453985821.7627.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <a703ec.53db.152885f2292.Coremail.yizhouzhou@ict.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zhouyi Zhou <zhouzhouyi@gmail.com>, pablo@netfilter.org,
	kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35907 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933788AbcA1OAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 09:00:53 -0500
In-Reply-To: <a703ec.53db.152885f2292.Coremail.yizhouzhou@ict.ac.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-28 at 21:14 +0800, Zhouyi Zhou wrote:

> My patch is intend to prevent kernel panic, to prevent reading garbage
> or read data from a prior frame and leak secrets, the prototypes of the 
> get_h2x5_addr functions and the functions that call get_h2x5_addr should
> be changed, should we do this? 

In term of security, panics are better than allowing attacker to read
data from other people, like a password.

BTW, are you able to trigger any panic ?

I am not familiar with this code, it is not obvious.

If a fix is needed, better doing it right.
