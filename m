From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Sun, 25 Nov 2007 22:15:44 -0800
Message-ID: <adahcj9sfan.fsf@cisco.com>
References: <20071122343.446909000@suse.de> <adatznarrzc.fsf@cisco.com>
	<200711261228.15155.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:18353 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498AbXKZGP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 01:15:58 -0500
In-Reply-To: <200711261228.15155.rusty@rustcorp.com.au> (Rusty Russell's message of "Mon, 26 Nov 2007 12:28:14 +1100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Except C doesn't have namespaces and this mechanism doesn't create them.  So 
 > this is just complete and utter makework; as I said before, noone's going to 
 > confuse all those udp_* functions if they're not in the udp namespace.

I don't understand why you're so opposed to organizing the kernel's
exported symbols in a more self-documenting way.  It seems pretty
clear to me that having a mechanism that requires modules to make
explicit which (semi-)internal APIs makes reviewing easier, makes it
easier to communicate "please don't use that API" to module authors,
and takes at least a small step towards bringing the kernel's exported
API under control.  What's the real downside?

 - R.
