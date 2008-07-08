From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 reverts.... PLEASE READ
Date: Tue, 08 Jul 2008 01:55:48 -0700 (PDT)
Message-ID: <20080708.015548.127198943.davem@davemloft.net>
References: <20080707.224336.59099363.davem@davemloft.net>
	<20080708070106.GA30382@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39239
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751240AbYGHIzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 04:55:48 -0400
In-Reply-To: <20080708070106.GA30382@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 8 Jul 2008 09:01:06 +0200

> David Miller <davem@davemloft.net> :
> [...]
> > Some defconfig files got modified in the NAPI config option removal
> > commits that went in yesterday, and that's not supposed to happen.
> 
> Is it a matter of keeping the option for a longer time or should they
> not go away under any circumstance ?

The issue is that defconfig updates should stay out of the
subsystem trees.

Otherwise we get conflicts with the arch maintainer trees,
and also "make oldconfig" works perfectly fine without
the defconfig change.
