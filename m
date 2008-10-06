From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH to REVERT] Re: ax25 rose Re: kernel panic
 linux-2.6.27-rc7
Date: Mon, 06 Oct 2008 13:05:11 -0700 (PDT)
Message-ID: <20081006.130511.192478355.davem@davemloft.net>
References: <20081005204013.GB2526@ami.dom.local>
	<1223241500.18094.32.camel@f6bvp-5>
	<20081005220510.GA2613@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f6bvp@free.fr, netdev@vger.kernel.org, ralf@linux-mips.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56840
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752422AbYJFUFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 16:05:36 -0400
In-Reply-To: <20081005220510.GA2613@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 6 Oct 2008 00:05:10 +0200

> So, I think we could agree with this:
> 
> 1. Reverting this patch fixes the oops which started this thread:
> 
> 	commit 30902dc3cb0ea1cfc7ac2b17bcf478ff98420d74
> 	Author: David S. Miller <davem@davemloft.net>
> 	Date:   Tue Jun 17 21:26:37 2008 -0700
> 
> 	ax25: Fix std timer socket destroy handling.
> 
> 2. Alternative (original) fix proposed by Tihomir Hidelberg:
> 	http://marc.info/?l=linux-netdev&m=121370472223572&w=2 
>    doesn't seem to cause any problems.
> 
> David, please reconsider these changes as reported and tested
> by Bernard.

Ok, I'll do this in the net-2.6 tree.

Thanks for the analysis and report everyone.
