From: Ben Greear <greearb@candelatech.com>
Subject: Re: network interface cards native vlans support in linux kernel?
Date: Fri, 11 Jul 2003 10:11:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0EEFDD.8050300@candelatech.com>
References: <Pine.LNX.4.44.0307111754220.6646-100000@hl.kauneta.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrius Kasparavicius <andrius@andrius.org>
In-Reply-To: <Pine.LNX.4.44.0307111754220.6646-100000@hl.kauneta.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrius Kasparavicius wrote:
> on vanilla linux kernel, eepro doesn't work, and with 1496 mtu, 8139too
> works with any mtu (and 1500).
> 
> which is recommended to use, e100 or eepro100?

As I mentioned, the e100 (intel's driver) is the one I recommend.

eepro100 does not seem to be updated in the kernel anymore, though if you go figure
out how to install Becker's drivers, he may have it working with vlans
by now.

Ben

> 
> Andrius.
> 
> On Wed, 9 Jul 2003, Ben Greear wrote:
> 
> 
>>>is there any problems to include full vlans support?
>>
>>Intel's e100 driver (and all NICs supported by it) support vlans
>>fine, as do most of the GigE NICs.  Tulip does not, last I hear, though
>>a work-around patch has been around forever.  Realtek worked at one time,
>>not sure about now though...
> 
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
