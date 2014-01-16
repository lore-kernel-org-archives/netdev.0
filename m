From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 11/13] net: mvneta: implement rx_copybreak
Date: Thu, 16 Jan 2014 10:36:40 +0100
Message-ID: <20140116093640.GA16457@1wt.eu>
References: <1389856819-6503-1-git-send-email-w@1wt.eu> <1389856819-6503-12-git-send-email-w@1wt.eu> <063D6719AE5E284EB5DD2968C1650D6D45D866@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55506 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751520AbaAPJgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 04:36:47 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D45D866@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 09:14:00AM +0000, David Laight wrote:
> From: Of Willy Tarreau
> > calling dma_map_single()/dma_unmap_single() is quite expensive compared
> > to copying a small packet. So let's copy short frames and keep the buffers
> > mapped. We set the limit to 256 bytes which seems to give good results both
> > on the XP-GP board and on the AX3/4.
> 
> Have you tried something similar for transmits?
> Copying short tx into a preallocated memory area that is dma_mapped
> at driver initialisation?

Not yet by lack of time, but I intend to do so. Both the NIC and the driver
are capable of running at line rate (1.488 Mpps) when filling descriptors
directly, so many improvements are still possible.

Regards,
Willy
