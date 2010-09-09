From: David Miller <davem@davemloft.net>
Subject: Re: Is via-velocity broken in 2.6.34?
Date: Thu, 09 Sep 2010 12:57:10 -0700 (PDT)
Message-ID: <20100909.125710.226781968.davem@davemloft.net>
References: <AANLkTi=kbonQ11mLpkd4EnSr3ch8yDssnjaUsgw_tVw9@mail.gmail.com>
	<20100908.083022.189687100.davem@davemloft.net>
	<AANLkTimRPOD857-pFXUJPxBw0RYXYe8OiPFwisY28x5B@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: matt.causey@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38291
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752854Ab0IIT4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 15:56:52 -0400
In-Reply-To: <AANLkTimRPOD857-pFXUJPxBw0RYXYe8OiPFwisY28x5B@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Causey <matt.causey@gmail.com>
Date: Thu, 9 Sep 2010 10:42:21 -0700

> So it wasn't immediately intuitive that we would need power
> management enabled in order to use other parts of the system.

ACPI is not power management.

It's a set of infrastructure (including an interpreter and small
firmware programs to drive specialized hardware) that allows the
important details of your motherboard to be described accurately to
the kernel by firmware authors.

That's why it's called "Advanced Configuration and Power Interface"
and not just "Advanced Power Interface" :-)

It also provides more accurate tables to describe things like
the cpus in your system etc., to replace deprecated mechanisms
for that such as MPS.
