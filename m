From: Ben Greear <greearb@candelatech.com>
Subject: Re: [EXPERIMENTAL PATCH] 2.4 tulip jumbo frames
Date: Fri, 19 Dec 2003 22:22:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FE3EAAA.6020608@candelatech.com>
References: <20031209160632.D1345@sygehus.dk> <3FD5FC36.5090405@pobox.com> <20031209223214.A1855@sygehus.dk> <3FD64EC9.6010203@candelatech.com> <20031209224906.M53356@sygehus.dk> <20031219153242.B1390@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031219153242.B1390@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rask Ingemann Lambertsen wrote:
> On Wed, Dec 10, 2003 at 12:40:02AM +0100, Rask Ingemann Lambertsen wrote:
> 
> 
>>That said, even checking CONFIG_VLAN_8021Q is probably flawed too, because 
>>ideally, even when building a kernel without VLAN support, you should be able 
>>to use the bridging support in a VLAN environment. IMHO. I mean, if this is 
>>not the case, please remind me why we need VLAN patches in the first place 
>>since setting an MTU of 1496 bytes works with every Ethernet board and driver.
> 
> 
> Further, why is it not the responsibility of vconfig to ensure that the MTU
> of the VLAN device is 4 lower than that of the underlying, "bare" Ethernet
> device?

Because correctly patched drivers can have eth0 with MTU 1500 and vlan eth0.5 with
MTU of 1500 as well.  I do not want to add artificial policy in vconfig or the
kernel,though of course users can hack up the MTU settings manually as
desired...

Ben


-- 
Ben Greear <greearb@candelatech.com>          <Ben_Greear@excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
