From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] net/sched/sch_generic.c: fix an error pointer
Date: Fri, 27 Jun 2008 19:51:50 -0700 (PDT)
Message-ID: <20080627.195150.131371077.davem@davemloft.net>
References: <20080619153714.5614d5be@hack>
	<20080619.161108.23678497.davem@davemloft.net>
	<20080621195526.GA25715@hack.netcabo.pt>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wcong@critical-links.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39397
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751932AbYF1Cvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 22:51:50 -0400
In-Reply-To: <20080621195526.GA25715@hack.netcabo.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: WANG Cong <xiyou.wangcong@gmail.com>
Date: Sat, 21 Jun 2008 20:55:26 +0100

> ERR_PTR() ususally encodes an negative errno, not positive.
> 
> Note, in the following patch, 'err' is initialized as:
> 
> int err = -ENOBUFS;
> 
> Signed-off-by: WANG Cong <wcong@critical-links.com>

Patch applied, th anks.
