From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Avoid gettimeofday when not needed
Date: Wed, 31 Mar 2004 10:53:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406B13B7.6090403@candelatech.com>
References: <200403311201.i2VC13D19579@zero.aec.at>	<Pine.LNX.4.58.0403311552070.19615@rhea.tcs.hut.fi>	<20040331135449.GB62402@colin2.muc.de>	<Pine.LNX.4.58.0403311705460.19615@rhea.tcs.hut.fi>	<20040331151047.GA6033@colin2.muc.de>	<406B001A.1030901@candelatech.com> <20040331195020.4fff9171.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, vnuorval@tcs.hut.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040331195020.4fff9171.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

>>Why not add a 32-bit field to the skb to handle various flag needs
>>going forward?
> 
> 
> That is what ->cb already is

 From the comments, it appears each layer can write over these,
and since it's just a block of bytes, it is difficult to understand
what each bit/field is used for.

It still seems to me that a bit-field with well defined
flags is more useful.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
