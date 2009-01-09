From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] b44: fix misalignment and wasted space in rx handling
Date: Fri, 9 Jan 2009 11:35:37 +0100
Message-ID: <200901091135.38079.mb@bu3sch.de>
References: <4966C21F.5020700@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:43329 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705AbZAIKgz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 05:36:55 -0500
In-Reply-To: <4966C21F.5020700@openwrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 09 January 2009 04:18:55 Felix Fietkau wrote:
> Broadcom 4400 puts a header of configurable size (apparently needs
> to be at least 28 bytes) in front of received packets. When handling
> this, the previous code accidentally added the offset 30 *twice* for
> the software and once for the hardware, thereby cancelling out the
> IP alignment effect of the 30 byte padding and wasting an additional
> 30 bytes of memory per packet.
> 
> This patch fixes this problem and improves routing throughput by
> about 30% on MIPS, where unaligned access is expensive.

Very nice fix, indeed.
Too bad the patch is line wrapped :)

-- 
Greetings, Michael.
