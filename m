From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 9 Dec 2016 08:05:39 -0500
Message-ID: <80471630-f5fb-1352-9c4f-dffeb129206c@pobox.com>
References: <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd@pobox.com>
 <20161125095350.GA20653@kroah.com>
 <1816ec7e-2733-f4ba-5d30-29dbabd20aad@pobox.com>
 <20161125.115827.2014848246966159357.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB201057793@RTITMBSV03.realtek.com.tw>
 <0835B3720019904CB8F7AA43166CEEB20105C9EE@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB20105C9EE@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-12-08 10:23 PM, Hayes Wang wrote:
> Mark Lord <mlord@pobox.com>
> 
> I find an issue about autosuspend, and it may result in the same
> problem with you. I don't sure if this is helpful to you, because
> it only occurs when enabling the autosuspend.

Thanks.  I am using ASIX adapters now.

I did try the latest 4.9-rc8, and 4.8.12 kernels with the r8152 dongle yesterday,
in hope that perhaps the many EHCI fixes from those kernels might help out.

The dongle was unusable with those newer kernels.
Most of the time it failed with "Get ether addr fail\n" at startup.

On the occasions where it got past that point, it often failed
the DHCP negotiation, but this looks more like a bug elsewhere in
the kernel, possibly racing against initialization of the random
number generators.  Adding a 2-second sleep the the r8151 probe
function made this error mostly go away.

Cheers
-- 
Mark Lord
