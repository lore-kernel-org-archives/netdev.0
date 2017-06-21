From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH net-next 1/2] ldmvsw: add vio version and remote-mac to
 ethtool info
Date: Wed, 21 Jun 2017 13:59:35 -0700
Message-ID: <732eb629-450f-bfae-4535-0c6e5b2ccbe0@oracle.com>
References: <1498061394-233018-1-git-send-email-shannon.nelson@oracle.com>
 <1498061394-233018-2-git-send-email-shannon.nelson@oracle.com>
 <20170621.150546.230947714652245325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170621.150546.230947714652245325.davem@davemloft.net>
Content-Language: en-US
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/21/2017 12:05 PM, David Miller wrote:
> From: Shannon Nelson <shannon.nelson@oracle.com>
> Date: Wed, 21 Jun 2017 09:09:53 -0700
> 
>> In the ethtool -i output print the vio version and the remote-mac
>> of the ldom that the vif device is serving as this vif info is
>> not exposed elsewhere.  The remote-mac address is most useful for
>> tracking which client ldom is being served by the vif.
>>
>> Orabug: 26316362
>>
>> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
> 
> Although less useful, it is exposed already via the kernel logs.

I had thought about that, but the idea of parsing kernel logs that could 
expire away didn't thrill me.

> 
> Also, this is not at all an appropriate place to expose this.  The
> "driver info" ethtool command is not a place to post per-connection
> or per-link information.

I knew it was a bit of a stretch, but almost made sense.  However, I'd 
still like to put the vio version here - is that acceptable?

> 
> Probably one of the IFLA_* netlink attributes would work best for
> this.  You could even use PHYS_PORT_ID for this, which gives you
> 32 bytes to work with.

Hmmm - good thought.  I'll go poke at this and see what I can come up 
with.  I gather from this that you agree that /sys is not the right 
place for this information, either.

Thanks,
sln
