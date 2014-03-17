From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next v3 1/2]r8152:addRTL8152_EARLY_AGG_TIMEOUT_SUPER
Date: Mon, 17 Mar 2014 14:01:23 +0800
Message-ID: <B2AB7D81B9814DE685426165CF613D72@realtek.com.tw>
References: <A56A13416A724183888BB62CEFD2B817@realtek.com.tw><20140314.000741.1829674011496195593.davem@davemloft.net><CE95F5CF3B924F0A921DDC3493A67365@realtek.com.tw> <20140314.144311.2001561184461945910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>,
	<nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140314.144311.2001561184461945910.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 From: David Miller [mailto:davem@davemloft.net] 
> Sent: Saturday, March 15, 2014 2:43 AM
[...]
> > Besides, I don't wish to modify the setting by ethtool when re-loading
> > the driver or rebooting every time.
> 
> You have code to reset the driver, you can do it when the user asks
> for the setting to be changed via ethtool.  I do not see this as
> a problem.
> 
> The ethtool change can occur while the driver is already up, you'll
> just need to reset the chip and make the new configuration, this is
> not a problem.

Thanks for your answer. I would study how to set it by ethtool. 

Best Regards,
Hayes
