From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/3] NetXen: Graceful teardown of interface and hardware
 upon module unload
Date: Sat, 30 Jun 2007 23:27:07 -0400
Message-ID: <46871F0B.6020801@garzik.org>
References: <20070630203844.256007454@netxen.com>	 <20070630204424.876510236@netxen.com>	 <200707010012.11527.mb@bu3sch.de> <4686DC81.5090908@garzik.org> <ab901500706301849h5f8e25c7k8e2c0a8f04dd3198@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	rob@netxen.com, Milan Bag <mbag@netxen.com>,
	Wen Xiong <wenxiong@us.ibm.com>
To: Dhananjay Phadke <dhananjay.phadke@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39603 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754952AbXGAD1L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2007 23:27:11 -0400
In-Reply-To: <ab901500706301849h5f8e25c7k8e2c0a8f04dd3198@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dhananjay Phadke wrote:
> This stage is safe to bail out on signal. It's initializing about a
> hundred registers
> and trying to guaranty by retrying, so can get stretched too much on 
> faulty h/w.

This implies that you have -add- code to check for and handle signals at 
each delay point.  Don't bother.  Too much code bloat for negligable gain.

It is better just to remove the _interruptible, for many reasons.

	Jeff



