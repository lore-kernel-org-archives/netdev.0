From: Ivan Mikhaylov <ivan@ru.ibm.com>
Subject: Re: [PATCH v2 1/2] ethtool: changes of emac_regs structure
 accordingly within driver emac_regs structure.
Date: Wed, 9 Sep 2015 15:28:01 +0400
Message-ID: <20150909152801.71019c58@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Aug 2015 15:10:00 +0400
Ivan Mikhaylov <ivan@ru.ibm.com> wrote:

>On Wed, 2015-08-05 at 15:01 +0400, Ivan Mikhaylov wrote:
>> * do the redefinition of emac_regs struct from driver structure
>> perspective and passing size from actual struct size, not from memory
>> area variable which set in dts file.
>> 
>> * passing variable from dts option may cause a problem with output
>> below MII's section which we're fixing with this and 5369c71 commit
>> in kernel.
>[...]
>
>But you still aren't handling the case where only one of the driver and
>ethtool is upgraded, even by reporting an error.
>
>I'm never going to apply patches to ethtool that obviously break binary
>compatibility, so you are wasting your time sending me new versions
>that do that.
>
>At this point you should probably just bump the dump version numbers in
>both places.
>
>Ben.
>
>-- 
>Ben Hutchings
>friends: People who know you well, but like you anyway.
>
>[unhandled content-type:application/pgp-signature]

Ben, thanks for looking to that. 

I decided to divide patches for 
1 - structure change which fixing problem
2 - add EMAC4SYNC
May be it wasn't clear from first patch...

There as a note to you with questions without answer:
https://lkml.org/lkml/2015/6/23/466

Also I said in that thread I can prove with table of 
 1. old ethtool old driver
 2. patched ethtool old driver
 3. patched ethtool patched driver
 4. old ethtool patched driver

if you want to see difference in output on machine what I've.
 
Can we talk on some irc channel to resolve that situation,
it will be much faster, where I can find you on irc.debian.org?

Thanks in advance.
