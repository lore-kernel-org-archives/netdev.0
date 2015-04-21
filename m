From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH 0/3] Enable connecting DSA-based switch to the USB
 RMII interface.
Date: Tue, 21 Apr 2015 10:51:07 -0700
Message-ID: <55368E0B.8060600@gmail.com>
References: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz> <20150421124737.GD32294@lunn.ch> <55368667.5030105@gmail.com> <20150421173902.GL32294@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jan Kaisrlik <kaisrja1@fel.cvut.cz>, sojkam1@fel.cvut.cz,
	tkonecny@retia.cz, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Kaisrlik <ja.kaisrlik@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150421173902.GL32294@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/04/15 10:39, Andrew Lunn wrote:
>>> I would however say that sysfs is the wrong API. The linux network
>>> stack uses netlink for most configuration activities. So i would
>>> suggest adding a netlink binding to DSA, and place the code in
>>> net/dsa/, not within an MDIO driver.
>>
>> I suppose we could do that, but that sounds like a pretty radical change
>> in how DSA is currently configured (that is statically at boot time),
>> part in order to allow booting from DSA-enabled network devices (e.g:
>> nfsroot).
> 
> We would keep both DT and platform device. But statically at boot does
> not work for a USB hotpluggable switch!

Is the switch really hotpluggable, or it is the USB-Ethernet adapter
connecting to it? If the former, then I agree, if not, I would imagine
that there is nothing that prevents creating the switch device first,
and wait for its "master_netdev" to show up later before it starts doing
anything useful?
-- 
Florian
