From: Kostya Belezko <bkostya@hotmail.com>
Subject: RE: [PATCH v2][Nios2-dev] Altera TSE: Add missing phydev
Date: Fri, 2 Jan 2015 15:57:29 -0500
Message-ID: <SNT146-W41ED8A3C5CE762B5F35C15B65D0@phx.gbl>
References: <BLU437-SMTP8237F72A0A7CCFCAF201F6B65E0@phx.gbl>,<20150102.154500.2104526152897268790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "nios2-dev@lists.rocketboards.org" <nios2-dev@lists.rocketboards.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snt004-omc4s43.hotmail.com ([65.54.51.94]:56253 "EHLO
	SNT004-OMC4S43.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752074AbbABVCb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2015 16:02:31 -0500
In-Reply-To: <20150102.154500.2104526152897268790.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----------------------------------------
> Date: Fri, 2 Jan 2015 15:45:00 -0500
> To: bkostya@hotmail.com
> CC: nios2-dev@lists.rocketboards.org; netdev@vger.kernel.org
> Subject: Re: [PATCH v2][Nios2-dev] Altera TSE: Add missing phydev
> From: davem@davemloft.net
>
> From: Kostya Belezko <bkostya@hotmail.com>
> Date: Tue, 30 Dec 2014 12:27:09 -0500
>
>> Altera network device doesn't come up after
>>
>> ifconfig eth0 down
>> ifconfig eth0 up
>>
>> The reason behind is clearing priv->phydev during tse_shutdown().
>> The phydev is not restored back at tse_open().
>>
>> Resubmiting as to follow Tobias Klauser suggestion.
>> phy_start/phy_stop are called on each ifup/ifdown and
>> phy_disconnect is called once during the module removal.
>>
>> Signed-off-by: Kostya Belezko <bkostya@hotmail.com>
>
> I'll apply this, but I'm pretty sure the phy_disconnect() is down
> so that the PHY is powered down when the device is not up.

Hi David,
What do you mean by phy_disconnect() is down?
Originally priv->phydev is NULL (and remains null forever) right after 'ifdown eth0'


 		 	   		  