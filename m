From: David Miller <davem@davemloft.net>
Subject: Re: [Lksctp-developers] SCTP: Fix dead loop while received
 unexpected chunk with length set to zero
Date: Thu, 30 Aug 2007 22:17:45 -0700 (PDT)
Message-ID: <20070830.221745.21927084.davem@davemloft.net>
References: <46D5901C.3010802@hp.com>
	<46D658B8.8070801@cn.fujitsu.com>
	<46D6C9F2.5020702@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, lksctp-developers@lists.sourceforge.net,
	netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58897
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758202AbXHaFRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 01:17:46 -0400
In-Reply-To: <46D6C9F2.5020702@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 30 Aug 2007 09:45:22 -0400

> But now we are doing the same thing twice (and this is not the only
> place).  I know I am being really picky here, but I am starting to
> thing the ootb handling\ is a mess and I really don't want to add to
> the mess.  Until I (or someone else) prove that it's not a mess or
> fix it, I am going to hold off on these patches.
>
> Feel free to go through the spec and fix all the OOTB handling.

I think you should reprioritize, because as Wei emphasized this
is remotely triggerable stuff.

I realize what a pain it is, but a band-aid fix is better than a
remote hole.
