From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH v2 net 6/6] net: mvneta: enable IP checksum with jumbo
 frames for Armada 38x on Port0
Date: Thu, 26 Nov 2015 19:41:29 +0100
Message-ID: <CAPv3WKcVd_85m025ew4Ev6UMTo6iRPsFf4ZGG37e2hwi4L7LKg@mail.gmail.com>
References: <1448561293-16431-1-git-send-email-mw@semihalf.com>
	<1448561293-16431-7-git-send-email-mw@semihalf.com>
	<20151126193301.67259f76@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	=?UTF-8?Q?Gregory_Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>, nadavh@marvell.com,
	Lior Amsalem <alior@marvell.com>,
	Evan Wang <xswang@marvell.com>,
	Yair Mahalalel <myair@marvell.com>, nitroshift@yahoo.com,
	Grzegorz Jaszczyk <jaz@semihalf.com>,
	Tomasz Nowicki <tn@semihalf.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:36028 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbbKZSla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 13:41:30 -0500
Received: by obdgf3 with SMTP id gf3so68599918obd.3
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 10:41:29 -0800 (PST)
In-Reply-To: <20151126193301.67259f76@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas,


2015-11-26 19:33 GMT+01:00 Thomas Petazzoni
<thomas.petazzoni@free-electrons.com>:
> Marcin,
>
> On Thu, 26 Nov 2015 19:08:13 +0100, Marcin Wojtas wrote:
>> The Ethernet controller found in the Armada 38x SoC's family support
>> TCP/IP checksumming with frame sizes larger than 1600 bytes, however
>> only on port 0.
>>
>> This commit enables it by setting 'tx-csum-limit' to 9800B in
>> 'ethernet@70000' node.
>>
>> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
>> Cc: <stable@vger.kernel.org> # v3.18+
>
> This and the previous patch is not a fix, and has no business going in
> stable. It is enabling a better functionality, but it is clearly not a
> fix.
>

Ok. I thought that patches enabling tx_csum_limit were adding a sort
of regression, but I can agree to your interpretation. In such case I
will leave stable notification only for patch #4.

Thanks,
Marcin
