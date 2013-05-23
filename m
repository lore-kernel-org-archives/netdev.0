From: David Miller <davem@davemloft.net>
Subject: Re: [net-next resend PATCH 1/6] net: cpsw: enhance pinctrl support
Date: Thu, 23 May 2013 12:10:37 -0700 (PDT)
Message-ID: <20130523.121037.84357412382839522.davem@davemloft.net>
References: <1369130103-743-2-git-send-email-mugunthanvnm@ti.com>
	<20130522.235741.135665074490271750.davem@davemloft.net>
	<1BAFE6F6C881BF42822005164F1491C33EBF928C@DBDE04.ent.ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-omap@vger.kernel.org,
	benoit.cousson@linaro.orgm, paul@pwsan.com
To: gururaja.hebbar@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758293Ab3EWTKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 15:10:40 -0400
In-Reply-To: <1BAFE6F6C881BF42822005164F1491C33EBF928C@DBDE04.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Hebbar, Gururaja" <gururaja.hebbar@ti.com>
Date: Thu, 23 May 2013 11:28:38 +0000

> On Thu, May 23, 2013 at 12:27:41, David Miller wrote:
>> From: Mugunthan V N <mugunthanvnm@ti.com>
>> Date: Tue, 21 May 2013 15:24:58 +0530
>> 
>> > +		priv->pins_default = pinctrl_lookup_state(priv->pinctrl,
>> > +						PINCTRL_STATE_DEFAULT);
>> 
>> This is not indented correctly.
>> 
>> Argument on the second, and subsequent, lines of a function call
>> must start at the first column after the openning parenthesis of
>> the function call itself.
> 
> Well, if I am correct, doing so will make the line cross 80 character limit.
> If you could (please I ask), can you let me know how it can be handled in 
> above situation. I will make the changes/corrections and re-send it.
> 
> Thanks a lot in advance.

Avoid the deep indentation by coding the basic block into a helper
function.
