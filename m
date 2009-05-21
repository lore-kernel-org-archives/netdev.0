From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] NIU: fix spurious interrupts
Date: Wed, 20 May 2009 17:37:36 -0700 (PDT)
Message-ID: <20090520.173736.164783244.davem@davemloft.net>
References: <4A132A0F.8070800@windriver.com>
	<20090519.150156.115978100.davem@davemloft.net>
	<4A14285C.1040705@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matheos.worku@sun.com
To: hong.pham@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37626
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752341AbZEUAhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 20:37:38 -0400
In-Reply-To: <4A14285C.1040705@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Hong H. Pham" <hong.pham@windriver.com>
Date: Wed, 20 May 2009 11:57:16 -0400

> I've added the suggested instrumentations to dump out the LD interrupt
> registers
> when spurious interrupts occur.  Attached below is a kernel log.
> 
> In all cases, interrupts are being generated even though the LDG has
> been disarmed!

Thanks for doing this testing, I'll think about how to
attack this bug.
