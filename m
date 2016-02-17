From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: Add support for phy-handle binding
Date: Wed, 17 Feb 2016 13:55:15 -0500 (EST)
Message-ID: <20160217.135515.2062303835595535344.davem@davemloft.net>
References: <1455379368-18739-1-git-send-email-nathan@nathanrossi.com>
	<20160217.121414.529895298809970981.davem@davemloft.net>
	<CA+aJhH13H87z4=SBvZaOjND3RZRDSyxBp1ctYD5ssHKHg5eToQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nicolas.ferre@atmel.com
To: nathan@nathanrossi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+aJhH13H87z4=SBvZaOjND3RZRDSyxBp1ctYD5ssHKHg5eToQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nathan Rossi <nathan@nathanrossi.com>
Date: Thu, 18 Feb 2016 04:44:35 +1000

> On Thu, Feb 18, 2016 at 3:14 AM, David Miller <davem@davemloft.net> wrote:
>> All of these special cases we use (all the DT bindings are in text
>> files in the kernel sources, we control all of the bootloaders, etc.)
>> is the most shaky foundation I've ever seen upon which to erect a
>> stable device probing mechanism.
>>
>> I'm not applying this patch until you add an error handling path from
>> the of_phy_connect() call that will do the existing PHY probing sequence
>> by hand using phy_find_first().
> 
> I am not quite sure how to handle that in a way such as to also allow
> for the probe deferral in the event that the phydev/mdio bus which the
> phy-handle points at is not yet probed itself. But I guess the real
> question is whether or not to handle the deferral at all?

I think we need some experts in this area to chime in on this issue.
