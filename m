From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Sun, 22 Nov 2015 22:37:56 +0100
Message-ID: <CAPv3WKfqpBgjERwU3VTPeM7NRkSzz=Ny13WhLvbT_yHfaG1nWw@mail.gmail.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
	<12984648.7CKVgBs7pu@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Yair Mahalalel <myair@marvell.com>,
	Grzegorz Jaszczyk <jaz@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Evan Wang <xswang@marvell.com>, nadavh@marvell.com,
	Lior Amsalem <alior@marvell.com>,
	Tomasz Nowicki <tn@semihalf.com>,
	=?UTF-8?Q?Gregory_Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>, nitroshift@yahoo.com,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:35383 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699AbbKVVh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 16:37:57 -0500
Received: by oige206 with SMTP id e206so103401701oig.2
        for <netdev@vger.kernel.org>; Sun, 22 Nov 2015 13:37:57 -0800 (PST)
In-Reply-To: <12984648.7CKVgBs7pu@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd,

2015-11-22 21:06 GMT+01:00 Arnd Bergmann <arnd@arndb.de>:
> On Sunday 22 November 2015 08:53:46 Marcin Wojtas wrote:
>>
>> 3. Optimisations - concatenating TX descriptors' flush, basing on
>> xmit_more support and combined approach for finalizing egress processing.
>> Thanks to HR timer buffers can be released with small latency, which is
>> good for low transfer and small queues. Along with the timer, coalescing
>> irqs are used, whose threshold could be increased back to 15.
>>
>>
>
> If you are already reworking the TX path, it probably makes sense to
> support BQL as well, see the Marvell skge and sky2 drivers for examples
> using netdev_{tx_,}{sent,completed}_queue.
>

Good idea, I'll take a look.

Best regards,
Marcin
