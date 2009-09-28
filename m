From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3 and Broadcom PHY driver
Date: Mon, 28 Sep 2009 13:52:26 -0700
Message-ID: <20090928205226.GB12652@xw6200.broadcom.net>
References: <4ABE8862.3060308@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Felix Radensky" <felix@embedded-sol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3138 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753219AbZI1Uw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2009 16:52:26 -0400
In-Reply-To: <4ABE8862.3060308@embedded-sol.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 26, 2009 at 02:32:18PM -0700, Felix Radensky wrote:
> Hi,
> 
> I've noticed that in linux-2.6.31 I have to make tg3 driver modular, due to
> its dependency on Broadcom PHY driver. If both tg3 and PHY driver are
> compiled into the kernel, tg3 fails to detect a PHY, apparently because PHY
> driver is loaded later. I'm using BCM57760 on embedded powerpc platform
> (MPC8536).
> 
> How can I make tg3 work when it's compiled into the kernel ?
> 
> Thanks.

Is the broadcom module also compiled into the kernel?

