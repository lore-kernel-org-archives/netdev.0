From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] PowerPC: Add BCM5248 and Marvell 88E1111 PHY support to NEW EMAC.
Date: Tue, 23 Oct 2007 11:13:48 -0500
Message-ID: <38505C5B-4252-4AA7-B4F5-6B5267A6DBAA@kernel.crashing.org>
References: <20071015175717.GA4602@ru.mvista.com> <4713B10B.5000607@garzik.org> <20071023102035.6d35d3fe@weaponx.rchland.ibm.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Valentine Barshak <vbarshak@ru.mvista.com>,
	Michael Ellerman <michael@ellerman.id.au>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37966 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752196AbXJWQPV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 12:15:21 -0400
In-Reply-To: <20071023102035.6d35d3fe@weaponx.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Oct 23, 2007, at 10:20 AM, Josh Boyer wrote:

> On Mon, 15 Oct 2007 14:27:23 -0400
> Jeff Garzik <jeff@garzik.org> wrote:
>
>> Valentine Barshak wrote:
>>> This patch adds BCM5248 and Marvell 88E1111 PHY support to NEW  
>>> EMAC driver.
>>> These PHY chips are used on PowerPC 440EPx boards.
>>> The PHY code is based on the previous work by Stefan Roese  
>>> <sr@denx.de>
>>>
>>> Signed-off-by: Stefan Roese <sr@denx.de>
>>> Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
>>> ---

You guys should really look at moving emac over to the phylib so we  
don't have to duplicate drivers for the same phys all over the place :)

- k
