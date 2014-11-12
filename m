From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: phy: add module_phy_driver macro
Date: Wed, 12 Nov 2014 13:53:32 -0500 (EST)
Message-ID: <20141112.135332.1998100994393436738.davem@davemloft.net>
References: <1415731559-10015-1-git-send-email-johan@kernel.org>
	<54626015.3030907@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johan@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54626015.3030907@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 11 Nov 2014 11:14:29 -0800

> On 11/11/2014 10:45 AM, Johan Hovold wrote:
>> Add module_phy_driver macro that can be used by PHY drivers that only
>> calls phy_driver_register or phy_drivers_register (and the corresponding
>> unregister functions) in their module init (and exit).
>> 
>> This allows us to eliminate a lot of boilerplate code.
>> 
>> Split in three patches (actual macro and two driver change classes) in
>> order to facilitate review.
> 
> Looks good to me:
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Series applied, thanks.
