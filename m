From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [IOC3] Fix link autonegotiation timer.
Date: Sat, 17 Feb 2007 15:38:52 -0500
Message-ID: <45D767DC.7000902@garzik.org>
References: <20070217025115.GA20247@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47920 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932846AbXBQUix (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:38:53 -0500
In-Reply-To: <20070217025115.GA20247@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> Start link negotiation in the open method.  Previously it was started
> on driver initialialization and shutdown on close so an ifdown would
> have results in closing negotiation for good.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

applied


