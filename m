From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Sun, 15 Mar 2009 20:15:36 -0700 (PDT)
Message-ID: <20090315.201536.108684950.davem@davemloft.net>
References: <200903141049.43202.rusty@rustcorp.com.au>
	<20090315.195806.97939686.davem@davemloft.net>
	<200903161343.13894.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pktoss@gmail.com, dcbw@redhat.com, netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39290
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752999AbZCPDPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 23:15:49 -0400
In-Reply-To: <200903161343.13894.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 16 Mar 2009 13:43:13 +1030

> On Monday 16 March 2009 13:28:06 David Miller wrote:
> > > Or should all devices which can't detect carrier set it to on, so
> > > older NetworkManagers work?
> > 
> > It is my opinion that this is the only correct behavior.
> > 
> > If you don't know, it's on.  Because "on" means "usable".  And you
> > can't fault NetworkManager or any other tool for making that kind of
> > decision.
> 
> Yes, I agree that NM has to assume unknown == on.  But I still think the
> kernel is right as it is to return -EOPNOTSUPP and let userspace deal with it.
> 
> "Let's fix broken userspace in the kernel" arguments make me nervous ;)

This is right from one perspective.

But from another, -EOPNOTSUPP means "half-written driver, kick maintainer"
:-)
