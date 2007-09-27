From: =?ISO-8859-1?Q?Jochen_Vo=DF?= <voss@seehuhn.de>
Subject: Re: [PATCH] sky2: sky2 FE+ receive status workaround
Date: Thu, 27 Sep 2007 09:14:11 +0100
Message-ID: <4C6E8545-ADDC-456E-B17B-B3512A6047D1@seehuhn.de>
References: <20070926175847.706025d0@freepuppy.rosehill>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seehuhn.de ([80.68.93.199]:3125 "EHLO seehuhn.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753231AbXI0IwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 04:52:09 -0400
In-Reply-To: <20070926175847.706025d0@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On 27 Sep 2007, at 01:58, Stephen Hemminger wrote:
> +	/* This chip has hardware problems that generates bogus status.
> +	 * So do only marginal checking and expect higher level protocols
> +	 * to handle crap frames.
> +	 */
> +	if (sky2->hw->chip_id == CHIP_ID_YUKON_FE_P &&
> +	    sky2->hw->chip_rev == CHIP_REV_YU_FE2_A0 &&
> +	    length != count)
> +		goto okay;

Shouldn't the condition be "length == count"?

I hope this helps,
Jochen
--
http://seehuhn.de/


