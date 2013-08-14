From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: Re: [PATCH 4/7] mfd: add MFD based flexcard driver
Date: Wed, 14 Aug 2013 10:12:47 +0200
Message-ID: <20130814101247.3ad43494@mitra.spranger.biz>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
	<1376384922-8519-6-git-send-email-b.spranger@linutronix.de>
	<20130813095508.GA5109@lee--X1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Holger Dengler <dengler@linutronix.de>
To: Lee Jones <lee.jones@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:53540 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759379Ab3HNIMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 04:12:52 -0400
In-Reply-To: <20130813095508.GA5109@lee--X1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Aug 2013 10:55:08 +0100 Lee Jones <lee.jones@linaro.org> wrote:

> Wow, this is a huge patch which is going to be an insanely long,
> laborious and complex task to review it all.
This is a card with a "insane" amount of features:

1) a Interrupt controller
2) a DMA engine
3) up to 8 CAN devices
4) up to 4 FlexRay devices
5) a dozen different trigger sources
6) timer
7) timestamp counter

> Can you split this up into many patches?
Not sure how to split this up into a smaller and workable series of patches.
Maybe rip out the header and the DMA part into a separate patch.

Regards
    Benedikt Spranger
