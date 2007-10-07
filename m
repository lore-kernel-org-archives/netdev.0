From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: Re: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
Date: Sun, 07 Oct 2007 17:42:02 +0900 (JST)
Message-ID: <20071007.174202.121596339.takano@axe-inc.co.jp>
References: <Pine.LNX.4.64.0710041419560.31129@kivilampi-30.cs.helsinki.fi>
	<20071007.145100.00679926.takano@axe-inc.co.jp>
	<20071006.231714.41173786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	y-kodama@aist.go.jp
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:61297 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbXJGImM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2007 04:42:12 -0400
In-Reply-To: <20071006.231714.41173786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
Date: Sat, 06 Oct 2007 23:17:14 -0700 (PDT)

> From: TAKANO Ryousei <takano@axe-inc.co.jp>
> Date: Sun, 07 Oct 2007 14:51:00 +0900 (JST)
> 
> > BTW, what is difference among netdev-2.6, net-2.6 (net-2.6.24), and 
> > tcp-2.6? I am not familiar with linux kernel development process.
> 
> net-2.6.24 tree is current new development
> 
> net-2.6 tree is only bug fixes
> 
> tcp-2.6 is an old abandonded tree that holds lots of old
> TCP work, most of which is merged already, but one part
> (my RB-Tree SACK patches) are not integrated yet.

Thanks, and I got it.

I need to check the related recent posts (SACK block validation, sacktag 
cache usage, and RT-tree SACK) on this list.

Ryousei Takano
