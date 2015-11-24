From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Tue, 24 Nov 2015 17:47:17 +0100
Message-ID: <CAPv3WKc+NA58=sxXe-YhUZvE9ca0q=ZC5L9WZOvAevuWZhAnYw@mail.gmail.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
	<20151124.112253.2276973557484332376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, netdev@vger.kernel.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	=?UTF-8?Q?Gregory_Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>, nadavh@marvell.com,
	Lior Amsalem <alior@marvell.com>,
	Evan Wang <xswang@marvell.com>,
	Yair Mahalalel <myair@marvell.com>, nitroshift@yahoo.com,
	Grzegorz Jaszczyk <jaz@semihalf.com>,
	Tomasz Nowicki <tn@semihalf.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:35646 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667AbbKXQrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 11:47:17 -0500
Received: by obbnk6 with SMTP id nk6so17711376obb.2
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 08:47:17 -0800 (PST)
In-Reply-To: <20151124.112253.2276973557484332376.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Thanks for the remark. I will do the split and re-submit.

Best regards,
Marcin

2015-11-24 17:22 GMT+01:00 David Miller <davem@davemloft.net>:
>
> This patch series has a lot of problems.
>
> The worst one is that you are mixing bug fixes and new
> features/cleanups.
>
> You cannot do that.
>
> You _especially_ can't do that if you expect some of this stuff
> to be submitted to -stable too.
>
> Therefore you _must_ extract out the bug fixes, and submit those
> against 'net'.  And you must then wait for 'net' to be merged
> into 'net-next' before submitting the new feature patches.
>
> Furthermore, you should explicitly show what tree you are targetting
> your patches at, in your Subject lines.  In the form:
>
>         Subject: [PATCH $(TREE) N/M]
>
> Where $(TREE) is either 'net' or 'net-next'.
>
> THanks.
