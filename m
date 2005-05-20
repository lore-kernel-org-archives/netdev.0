From: Ben Greear <greearb@candelatech.com>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 14:58:05 -0700
Message-ID: <428E5D6D.1010803@candelatech.com>
References: <1116609329.31523.16.camel@rh4> <20050520194220.GA18259@havoc.gtf.org> <428E4DE2.1020002@pobox.com> <428E5185.1070602@candelatech.com> <20050520210938.GA23714@havoc.gtf.org> <1116620256.31523.23.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, davem@davemloft.net, netdev@oss.sgi.com,
        ffan@broadcom.com, lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1116620256.31523.23.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> On Fri, 2005-05-20 at 17:09 -0400, Jeff Garzik wrote:
> 
>>On Fri, May 20, 2005 at 02:07:17PM -0700, Ben Greear wrote:
>>
>>>I dig having the chipset manufacturer
>>>solidly behind the driver, like e1000!
>>
>>Clearly you have been asleep :)  Broadcom has been contributing actively
>>to tg3.
>>
> 
> 
> Yes, we are solidly behind tg3 and bnx2.

Excellent...sorry for my sleepiness :)

With regard to tg3, I (with the gracious help of the Intel driver folks)
have added the ability to receive the ethernet checksum on the end of the
skb, as well as tell the e1000 chipset to receive packets with bad checksums,
etc....

Assuming the tg3 chipset can do this, are there documents or code snippets
available to explain how to enable the feature?

I would like to add generic support for this to the ethtool API and allow
drivers to support it as they wish....  Of all my hacks, this one actually
doesn't require new ioctls or /proc file API..so maybe it has a chance of
getting accepted? :)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
