From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v7] ARM: net: JIT compiler for packet filters
Date: Mon, 13 Feb 2012 16:02:49 +0000
Message-ID: <20120213160248.GA25655@n2100.arm.linux.org.uk>
References: <1325937154-2656-1-git-send-email-mgherzan@gmail.com> <4F392DFD.4070600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, davem@davemloft.net
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:55220 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979Ab2BMQDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 11:03:05 -0500
Content-Disposition: inline
In-Reply-To: <4F392DFD.4070600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2012 at 04:36:29PM +0100, Mircea Gherzan wrote:
> Gentle ping. This patch has been in the tracking system for over a
> month. Is there any reason not to apply it in arm/for-next?

Yes.  It needs quite a review to make sure that there's absolutely no
possibility for userspace to be able to generate malicious ARM code
and then have it executed.  Or put it another way: security paranoia.

I'm afraid that I've not been able to look at it at all yet, and I
haven't seen anyone looking at the code from that aspect.
