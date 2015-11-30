From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Sun, 29 Nov 2015 21:02:10 -0500 (EST)
Message-ID: <20151129.210210.1777978635596463961.davem@davemloft.net>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
	<5655FF36.20202@gmail.com>
	<CAPv3WKc4zSmjtw_FeePCVCaq_aUubbCw_ggtxgxs0-7LwL7fHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
	linux@arm.linux.org.uk, jason@lakedaemon.net, myair@marvell.com,
	jaz@semihalf.com, simon.guinot@sequanux.org, xswang@marvell.com,
	nadavh@marvell.com, alior@marvell.com, tn@semihalf.com,
	gregory.clement@free-electrons.com, nitroshift@yahoo.com,
	sebastian.hesselbarth@gmail.com
To: mw@semihalf.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPv3WKc4zSmjtw_FeePCVCaq_aUubbCw_ggtxgxs0-7LwL7fHQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcin Wojtas <mw@semihalf.com>
Date: Sun, 29 Nov 2015 14:21:35 +0100

>> Looking at your patches, it was not entirely clear to me how the buffer
>> manager on these Marvell SoCs work, but other networking products have
>> something similar, like Broadcom's Cable Modem SoCs (BCM33xx) FPM, and
>> maybe Freescale's FMAN/DPAA seems to do something similar.
>>
>> Does the buffer manager allocation work by giving you a reference/token
>> to a buffer as opposed to its address? If that is the case, it would be
>> good to design support for such hardware in a way that it can be used by
>> more drivers.
> 
> It does not operate on a reference/token but buffer pointers (physical
> adresses). It's a ring and you cannot control which buffer will be
> taken at given moment.

He understands this, he's asking you to make an "abstraction".

FWIW, I know of at least one more chip that operates this way too and
the code I wrote for it, particularly the buffer management, took a
while to solidify.  Common helpers for this kind of situation would
have helped me back when I wrote it.
