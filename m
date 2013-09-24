From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] Allow userspace code to use flag IFA_F_SECONDARY to
 specify an ip address to be primary or secondary ip on an interface
Date: Tue, 24 Sep 2013 15:28:33 -0400 (EDT)
Message-ID: <20130924.152833.434453431118381771.davem@redhat.com>
References: <1380046281-6012-1-git-send-email-vincent.mc.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vincent.mc.li@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380046281-6012-1-git-send-email-vincent.mc.li@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vincent Li <vincent.mc.li@gmail.com>
Date: Tue, 24 Sep 2013 11:11:21 -0700

> the current behavior is when an IP is added to an interface, the primary
> or secondary attributes is depending on the order of ip added to the interface
> the first IP will be primary and second, third,... or alias IP will be secondary
> if the IP subnet matches
> 
> this patch add the flexiblity to allow user to specify an argument 'primary' or 'secondary'
> (use 'ip addr add ip/mask primary|secondary dev ethX ' from iproute2 for example) to specify
> an IP address to be  primary or secondary.
> 
> the reason for this patch is that we have a multi blade cluster platform sharing 'floating management ip'
> and also that each blade has its own management ip on the management interface, so whichever blade in the
> cluster becomes primary blade, the 'floating mangaement ip' follows it, and we want any of our traffic
> originated from the primary blade source from the 'floating management ip' for consistency. but in this
> case, since the local blade management ip is always the primary ip on the mangaement interface and 'floating
> management ip' is always secondary, kernel always choose the primary ip as source ip address. thus we would
> like to add the flexibility in kernel to allow us to specify which ip to be primary or secondary.
> 
> Signed-off-by: Vincent Li <vincent.mc.li@gmail.com>

When submitting a patch, please:

1) Specify an appropriate prefix for your subject line, indicating the
   subsystem.  "ipv4: " might be appropriate here.

2) Format your commit message so that lines do not exceed 80 columns.
   People will read using ASCII text based tools in 80 column
   terminals.
