From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
Date: Sun, 7 Oct 2007 18:11:44 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710071805380.19695@kivilampi-30.cs.helsinki.fi>
References: <20071004.184519.16476818.takano@axe-inc.co.jp>
 <Pine.LNX.4.64.0710041419560.31129@kivilampi-30.cs.helsinki.fi>
 <20071007.145100.00679926.takano@axe-inc.co.jp> <20071006.231714.41173786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, y-kodama@aist.go.jp
To: takano@axe-inc.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42979 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805AbXJGPLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2007 11:11:46 -0400
In-Reply-To: <20071006.231714.41173786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

...Dropped DaveM from cc, I guess he knows the things I describe below 
already... :-)

On Sat, 6 Oct 2007, David Miller wrote:

> From: TAKANO Ryousei <takano@axe-inc.co.jp>
> Date: Sun, 07 Oct 2007 14:51:00 +0900 (JST)
> 
> > BTW, what is difference among netdev-2.6, 

netdev-2.6 is for network device drivers (stuff under drivers/net)

> net-2.6 (net-2.6.24), and 
> > tcp-2.6? I am not familiar with linux kernel development process.
> 
> net-2.6.24 tree is current new development
> 
> net-2.6 tree is only bug fixes
> 
> tcp-2.6 is an old abandonded tree that holds lots of old
> TCP work, most of which is merged already, but one part
> (my RB-Tree SACK patches) are not integrated yet.

In addition, when Linus releases a new kernel (2.6.23), the net-2.6.24 
becomes net-2.6 (the old one ceases to exist). At some point of 2.6.24-rc 
series, net-2.6.25 gets opened by DaveM, usually it's not available right 
after closure of 2.6.24 merge window. ...Then again, the trees are 
again rotated when a next official release is made...


-- 
 i.
