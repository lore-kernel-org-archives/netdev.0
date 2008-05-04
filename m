From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] (revised) net/xfrm/xfrm_policy.c: replace timer with
 delayed_work
Date: Sat, 03 May 2008 18:37:46 -0700 (PDT)
Message-ID: <20080503.183746.01223933.davem@davemloft.net>
References: <alpine.LFD.1.10.0805021323470.3349@localhost.localdomain>
	<20080502.165455.24687234.davem@davemloft.net>
	<20080503144647.GF3986@hack>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	akpm@osdl.org, netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44331
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752027AbYEDBhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 21:37:46 -0400
In-Reply-To: <20080503144647.GF3986@hack>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: WANG Cong <xiyou.wangcong@gmail.com>
Date: Sat, 3 May 2008 22:46:49 +0800

> I thought it can go into -mm so that many other people can help
> me to test it. Since I didn't have the IPSec environment. ;(

You don't need an "IPSEC environment" (whatever that is) to test these
code paths.

It's very easy to setup simplistic IPSEC states and policies between
two computers using "setkey" and friends.
