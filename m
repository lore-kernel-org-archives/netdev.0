From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Tue, 27 Mar 2007 18:52:46 -0700 (PDT)
Message-ID: <20070327.185246.41635477.davem@davemloft.net>
References: <20070327.153025.45876618.davem@davemloft.net>
	<4609A42A.4040304@mvista.com>
	<4609B680.7070601@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mhuth@mvista.com, dagriego@gmail.com, davem@davemloft.ne,
	netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57490
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932760AbXC1Bwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 21:52:47 -0400
In-Reply-To: <4609B680.7070601@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 27 Mar 2007 20:27:44 -0400

> As a concrete example of a way I've used this type of feature is to 
> defend against a netkill [1] style attack, where the defense involves 
> making decisions about which connections to kill when memory gets 
> scarce.  It makes sense to do this with a system daemon, since an admin 
> might have an arbitrarily complicated policy as to which applications 
> and peers have priority for the memory.  This is too complicated to 
> distribute and enforce across all applications.  You could do this in 
> the kernel, but why if you don't have to?

On the contrary this sounds like an excellent task for
a netfilter based solution.
