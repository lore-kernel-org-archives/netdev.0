From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Module For Intercepting Fully Constructed IPv6 Packets
Date: Mon, 04 May 2009 10:57:27 +0200
Message-ID: <87y6tdgs94.fsf@basil.nowhere.org>
References: <49FA162F.4010306@evolution-systems.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Matthew Jakeman <matt@evolution-systems.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:35655 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbZEDI53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 04:57:29 -0400
In-Reply-To: <49FA162F.4010306@evolution-systems.co.uk> (Matthew Jakeman's message of "Thu, 30 Apr 2009 22:20:47 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthew Jakeman <matt@evolution-systems.co.uk> writes:


> I am pondering attempting to write a module that will allow me to
> intercept an IPv6 packet once it has been fully constructed (so just
> before it gets passed to the output interface). The point of this is
> so that I can play around with the packets construction however I
> please to try out a few things.

You need a netfilter module on the OUTPUT chain.  For further
questions on that please ask the netfilter mailing list.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
