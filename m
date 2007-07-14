From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] Blackfin ethernet driver: on chip ethernet MAC controller
 driver
Date: Sat, 14 Jul 2007 16:33:27 -0400
Message-ID: <46993317.3070203@garzik.org>
References: <1184438993.3140.23.camel@roc-laptop> <200707142138.36619.mb@bu3sch.de> <8bd0f97a0707141249y2c90a59cs356aa3cef357f721@mail.gmail.com> <200707142217.36361.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier.adi@gmail.com>, bryan.wu@analog.com,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46647 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761022AbXGNUdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2007 16:33:32 -0400
In-Reply-To: <200707142217.36361.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> Well, this bitfield _might_ be OK (although I don't like bitfields
> at all), but the above pointer casting stuff should really use
> leXX_to_cpu. It's so easy to use and it is easier to read and
> maintain the code afterwards.
> If the bitfield stays, a comment must be added.

Regardless of endian issues, the bitfield usage should go away.

	Jeff


