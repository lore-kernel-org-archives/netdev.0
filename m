From: Neil Horman <nhorman@redhat.com>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 16:26:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4148A561.5070401@redhat.com>
References: <4148991B.9050200@pobox.com> <Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, leonid.grossman@s2io.com,
        Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Jakma <paul@clubi.ie>
In-Reply-To: <Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Paul Jakma wrote:
> On Wed, 15 Sep 2004, Jeff Garzik wrote:
> 
>> Put simply, the "ultimate TOE card" would be a card with network 
>> ports, a generic CPU (arm, mips, whatever.), some RAM, and some 
>> flash.  This card's "firmware" is the Linux kernel, configured to run 
>> as a _totally indepenent network node_, with IP address(es) all its own.
>>
>> Then, your host system OS will communicate with the Linux kernel 
>> running on the card across the PCI bus, using IP packets (64K fixed MTU).
> 
> 
>> My dream is that some vendor will come along and implement such a 
>> design, and sell it in enough volume that it's US$100 or less. There 
>> are a few cards on the market already where implementing this design 
>> _may_ be possible, but they are all fairly expensive.
> 
> 
> The intel IXP's are like the above, XScale+extra-bits host-on-a-PCI card 
> running Linux. Or is that what you were referring to with "<cards exist> 
> but they are all fairly expensive."?
> 
>>     Jeff
> 
> 
> regards,

IBM's PowerNP chip was also very simmilar (a powerpc core with lots of 
hardware assists for DMA and packet inspection in the extended register 
area).  Don't know if they still sell it, but at one time I had heard 
they had booted linux on it.
Neil

-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/
