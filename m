From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/2] net: deprecate eth_change_mtu, remove
 usage
Date: Mon, 17 Oct 2016 13:15:13 -0400 (EDT)
Message-ID: <20161017.131513.135103913948374087.davem@davemloft.net>
References: <20161017172006.4d549daa@jkicinski-Precision-T1700>
        <20161017.124954.360760874377344385.davem@davemloft.net>
        <20161017180027.4936fa15@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: kubakici@wp.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017180027.4936fa15@jkicinski-Precision-T1700>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jakub Kicinski <kubakici@wp.pl>
Date: Mon, 17 Oct 2016 18:00:27 +0100

> On Mon, 17 Oct 2016 12:49:54 -0400 (EDT), David Miller wrote:
>> From: Jakub Kicinski <kubakici@wp.pl>
>> Date: Mon, 17 Oct 2016 17:20:06 +0100
>> 
>> > Please correct me if I'm wrong but it seems like we are now limiting
>> > _all_ ethernet drivers to ETH_DATA_LEN in net-next.  
>> 
>> No, because the driver can increase the netdev->max_mtu value as needed.
> 
> But since almost no driver is doing that, yet, right now in net-next
> jumbo frames are not possible, no?  I thought the idea was the leave
> the value at 0 so drivers can opt-in as needed but since setup_ether()
> is initializing to 1500 now all ethernet driver get a default of
> limiting to 1500.
> 
> IOW this patch made checks which were done only in eth_change_mtu()
> mandatory for all drivers.

The conversions he made were in cases where the driver's method was doing
exactly the same thing eth_change_mtu() does not.

He strictly worked to keep the behavior identical compared to before his
changes, please read his patches carefully.
