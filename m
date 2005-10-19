From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] skge support for Marvell chips in Toshiba laptops
Date: Wed, 19 Oct 2005 20:43:49 +0100
Message-ID: <4356A1F5.5010200@gentoo.org>
References: <200510191047.53212.jbarnes@virtuousgeek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750900AbVJSTnu@vger.kernel.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
In-Reply-To: <200510191047.53212.jbarnes@virtuousgeek.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jesse,

Jesse Barnes wrote:
> Here's a small patch to add the PCI ID and chip type of the chip in my 
> Toshiba laptop to the skge driver.  I haven't tested it much (just 
> insmoded it and run ethtool against the corresponding eth1 device), but 
> it doesn't crash my system, so unless this configuration has already 
> been tested and is known to have problems, it might be good to add this 
> patch.
> 
> I'll test some more with a real network when I get home.

The device ID you added (0x4351) is already claimed by the new sky2 driver.

Unless theres a mistake in sky2's device table, your laptop contains a 
Yukon-II adapter which is incompatible with the original Yukon chips (skge = 
Yukon, sky2 = Yukon-II).

On the other hand, I believe Stephen could do with some extra sky2 testing :)
You can find it in the latest -mm releases.

Daniel
