From: Kostya Belezko <bkostya@hotmail.com>
Subject: RE: [PATCH v2][Nios2-dev] Altera TSE: Add missing phydev
Date: Fri, 2 Jan 2015 16:16:34 -0500
Message-ID: <SNT146-W703EA22E7BC894479746F0B65D0@phx.gbl>
References: <BLU437-SMTP8237F72A0A7CCFCAF201F6B65E0@phx.gbl>,<20150102.154500.2104526152897268790.davem@davemloft.net>,<SNT146-W41ED8A3C5CE762B5F35C15B65D0@phx.gbl>,<20150102.160703.2063675003050187496.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "nios2-dev@lists.rocketboards.org" <nios2-dev@lists.rocketboards.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snt004-omc4s46.hotmail.com ([65.54.51.97]:63555 "EHLO
	SNT004-OMC4S46.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752120AbbABVQf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2015 16:16:35 -0500
In-Reply-To: <20150102.160703.2063675003050187496.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----------------------------------------
> Date: Fri, 2 Jan 2015 16:07:03 -0500
> To: bkostya@hotmail.com
> CC: nios2-dev@lists.rocketboards.org; netdev@vger.kernel.org
> Subject: Re: [PATCH v2][Nios2-dev] Altera TSE: Add missing phydev
> From: davem@davemloft.net
>
> From: Kostya Belezko <bkostya@hotmail.com>
> Date: Fri, 2 Jan 2015 15:57:29 -0500
>
>> What do you mean by phy_disconnect() is down?
>> Originally priv->phydev is NULL (and remains null forever) right after 'ifdown eth0'
>
> I'm saying that the code should probably keep phydev non-NULL and just
> take the PHY down/up during these events.

Yes, this is what the patch intends to achieve. It keeps phydev non-NULL and calls phy_stop, shy_start respectively.
phy_disconnect is called upon rmmod.
 		 	   		  