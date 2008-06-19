From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ax25.h unsigned long type for ax25 timers
Date: Thu, 19 Jun 2008 14:46:21 -0700 (PDT)
Message-ID: <20080619.144621.120746379.davem@davemloft.net>
References: <200806171504.38702.bpidoux@free.fr>
	<20080617.223050.266166325.davem@davemloft.net>
	<485A893E.4080405@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org
To: bpidoux@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37086
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751657AbYFSVqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 17:46:21 -0400
In-Reply-To: <485A893E.4080405@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernard Pidoux <bpidoux@free.fr>
Date: Thu, 19 Jun 2008 18:28:46 +0200

> Unfortunately I don't quite understand exactly why a structure in user 
> space cannot be changed.

Because there are userland binaries already compiled out there using
the current structure layout.  If we change the kernel, those binaries
stop using a datastructure that matches what the kernel is using.
Such binaries will break.

In generic, because of this, you can never change the layout of a
data structure exported to userland as a kernel interface.
