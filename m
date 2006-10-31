From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] ipv6: fix flowlabel seqfile handling
Date: Tue, 31 Oct 2006 10:41:52 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0610311037050.20787@d.namei>
References: <Pine.LNX.4.64.0610310034500.14627@d.namei>
 <20061031.004431.63126878.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:19931 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1423496AbWJaPlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 10:41:55 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061031.004431.63126878.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Oct 2006, David Miller wrote:

> From: James Morris <jmorris@namei.org>
> Date: Tue, 31 Oct 2006 01:20:21 -0500 (EST)
> 
> > There's a bug in the seqfile show operation for flowlabel objects, where 
> > each hash chain is traversed cumulatively for each element.  The following 
> > function is called for each element of each chain:
> 
> Wow, there are tons of bugs in the flowlabel code, at least
> judging by the number of them you've found in the past few
> days :-)

It seems that nobody is using them, otherwise they'd have hit these bugs 
long ago.



- James
-- 
James Morris
<jmorris@namei.org>
