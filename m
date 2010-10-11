From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1c: Add support for Atheros AR8152 and AR8152
Date: Mon, 11 Oct 2010 12:02:51 -0700 (PDT)
Message-ID: <20101011.120251.48500348.davem@davemloft.net>
References: <20101010.210304.71107535.davem@davemloft.net>
	<20101011184835.GA10049@tux>
	<20101011120128.2cd460c9@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lrodriguez@atheros.com, ben@decadent.org.uk,
	Luis.Rodriguez@Atheros.com, netdev@vger.kernel.org,
	Jie.Yang@atheros.com, linux-team@atheros.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48589
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755077Ab0JKTC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 15:02:29 -0400
In-Reply-To: <20101011120128.2cd460c9@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 11 Oct 2010 12:01:28 -0700

> On Mon, 11 Oct 2010 11:48:35 -0700
> "Luis R. Rodriguez" <lrodriguez@atheros.com> wrote:
>> @@ -132,7 +132,7 @@ static int atl1c_get_permanent_address(struct atl1c_hw *hw)
>>  			return -1;
>>  	}
>>  	/* Disable OTP_CLK */
>> -	if ((hw->nic_type == athr_l1c || hw->nic_type == athr_l2c)) {
>> +	if ((hw->nic_type == athr_l1c || hw->nic_type == athr_l2c_b)) {
>>  		otp_ctrl_data &= ~OTP_CTRL_CLK_EN;
>>  		AT_WRITE_REG(hw, REG_OTP_CTRL, otp_ctrl_data);
>>  		msleep(1);
>> 
> 
> Did you notice ((gratuitous extra parens))

Yeah let's kill that too while we're changing this.
