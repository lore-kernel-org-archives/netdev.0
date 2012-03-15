From: Mircea Gherzan <mgherzan@gmail.com>
Subject: Re: [PATCH v7] ARM: net: JIT compiler for packet filters
Date: Thu, 15 Mar 2012 08:23:43 +0100
Message-ID: <4F6198FF.90801@gmail.com>
References: <1325937154-2656-1-git-send-email-mgherzan@gmail.com> <4F392DFD.4070600@gmail.com> <20120213160248.GA25655@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, davem@davemloft.net
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:62477 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187Ab2COHXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 03:23:49 -0400
Received: by wejx9 with SMTP id x9so2496586wej.19
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 00:23:48 -0700 (PDT)
In-Reply-To: <20120213160248.GA25655@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 13.02.2012 17:02, schrieb Russell King - ARM Linux:
> On Mon, Feb 13, 2012 at 04:36:29PM +0100, Mircea Gherzan wrote:
>> Gentle ping. This patch has been in the tracking system for over a
>> month. Is there any reason not to apply it in arm/for-next?
> 
> Yes.  It needs quite a review to make sure that there's absolutely no
> possibility for userspace to be able to generate malicious ARM code
> and then have it executed.  Or put it another way: security paranoia.

Are there any specific security aspects you're thinking of? Leaks to
userspace, divisions by zero and invalid packet offsets are already
taken care of.

> I'm afraid that I've not been able to look at it at all yet, and I
> haven't seen anyone looking at the code from that aspect.

Thanks,
Mircea
