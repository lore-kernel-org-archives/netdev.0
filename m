From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 0/4] atlx: add atl2 support
Date: Tue, 09 Sep 2008 02:32:12 -0400
Message-ID: <48C6186C.4010600@redhat.com>
References: <20080909061247.GA17834@file.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com
To: jeff@garzik.org, netdev@vger.kernel.org,
	atl2-test@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43888 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751584AbYIIGhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 02:37:11 -0400
In-Reply-To: <20080909061247.GA17834@file.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Snook wrote:
> This patchset adds support for atl2 hardware to the atlx codebase.  It is
> functionally very similar to the out-of-tree 2.0.4 version that many distros
> have been shipping for a few months, though it adds a fix from Atheros to fix
> the problem of device resets under heavy bidirectional load.
> 
> The code needs a lot of janitorial work, and there's a lot of low-hanging fruit
> for merging similar atl1 code into the shared atlx code, but I think that work
> will go much faster once this is in-tree.  The driver is known to work well for
> laptop and desktop use.  The only major bugs are device initialization problems
> that manifest themselves immediately and obviously (the NIC doesn't work) with
> certain motherboards.
> 
> Please consider this for the 2.6.28 merge window.
> 
> -- Chris

Forgot to mention, this has been tested with no problems on an EeePC 701 
with the 2.6.26 kernel.  Some x86_64 and SMP testing would be nice, but 
this is based heavily on the atl1 code, which works fine with x86_64 and 
SMP.

-- Chris
