From: Andi Kleen <andi@firstfloor.org>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 14:54:12 +0200
Message-ID: <87vdxmr53f.fsf@basil.nowhere.org>
References: <200808220457.40892.denys@visp.net.lb>
	<20080826201406.GA24827@2ka.mipt.ru> <48B46B48.7030609@cosmosbay.com>
	<20080826205158.GA15266@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:59678 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036AbYH0MyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 08:54:21 -0400
In-Reply-To: <20080826205158.GA15266@2ka.mipt.ru> (Evgeniy Polyakov's message of "Wed, 27 Aug 2008 00:51:58 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:
>
> Yup, this innocent toys can end up with this such behaviour on modern
> highly loaded machines.

I and also other people had some patches to move the time stamp
measuring into the socket. This way the time stamping didn't need to
be enabled on all packets, only on those that actually end up at a
socket that requires the time stamp.

Unfortunately DaveM didn't like it because some bank wanted
different semantics, see the discussion in 
http://thread.gmane.org/gmane.linux.network/91679

Perhaps you can find out which bank it was and send them a bill for
your CPU time ;-)

-Andi

-- 
ak@linux.intel.com
