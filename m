From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] vlan: set sysfs device_type to 'vlan'
Date: Tue, 23 Oct 2012 09:14:14 -0700
Message-ID: <5086C256.20202@candelatech.com>
References: <1350885237-12998-1-git-send-email-cardoe@cardoe.com> <20121023.023647.2164665243829038911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cardoe@cardoe.com, kaber@trash.net, netdev@vger.kernel.org,
	systemd-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121023.023647.2164665243829038911.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/2012 11:36 PM, David Miller wrote:
> From: Doug Goldstein <cardoe@cardoe.com>
> Date: Mon, 22 Oct 2012 00:53:57 -0500
>
>> Sets the sysfs device_type to 'vlan' for udev. This makes it easier for
>> applications that query network information via udev to identify vlans
>> instead of using strrchr().
>>
>> Signed-off-by: Doug Goldstein <cardoe@cardoe.com>
>
> You're extremely misguided.  This change, in fact, makes it ten times
> harder for such applications to query such devices.

If the application doesn't care, it can use the old way (which at least
for me, involves string-comparing the driver name ethtool returns, which
sucks at best).

And applications that care might suddenly have more features, or be more
efficient when running on newer kernels..

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
