From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH 04/13] net: mvneta: enable suspend/resume support
Date: Thu, 26 Nov 2015 18:39:28 +0100
Message-ID: <CAPv3WKdT2WFQy_UksaoRMpd7hwUMAgDXz3sVRjNggEUagyjCxQ@mail.gmail.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
	<1448178839-3541-5-git-send-email-mw@semihalf.com>
	<87k2p67wqz.fsf@free-electrons.com>
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
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>, nadavh@marvell.com,
	Lior Amsalem <alior@marvell.com>,
	Evan Wang <xswang@marvell.com>,
	Yair Mahalalel <myair@marvell.com>, nitroshift@yahoo.com,
	Grzegorz Jaszczyk <jaz@semihalf.com>,
	Tomasz Nowicki <tn@semihalf.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87k2p67wqz.fsf@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gregory,


>> +     /* Reset link status */
>> +     pp->link = 0;
>> +     pp->duplex = -1;
>> +     pp->speed = 0;
>> +
>
> Would it be possible to add a kind of mvneta_port_power_down(pp,
> pp->phy_interface) here ? It would allow to save power in standby mode
> too.
>

Sure, I'll try it.

Best regards,
Marcin
