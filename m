From: Ben Greear <greearb@candelatech.com>
Subject: Re: network interface cards native vlans support in linux kernel?
Date: Wed, 09 Jul 2003 10:13:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0C4D27.20907@candelatech.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C93B9@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrius Kasparavicius <andrius@andrius.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Hen, Shmulik" <shmulik.hen@intel.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A014C93B9@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hen, Shmulik wrote:
> Do you mean "native" as in hardware acceleration offloading?
> If that's the case than the 8021q vlan module handshakes with the device driver to check for support and that's it. No need to do any settings on the device. In case there is no offloading support, the vlan module will take care of all stripping/inserting of the vlan tag into place.
> On the other hand, if the device cannot handle 1504 byte packets, it defines itself as "vlan challenged" and you can't use vlan on it at all.

Even challenged ones can work if you set your MTU (and all peer MTUs) to 4 less than normal,
ie 1496.

Ben

> 
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
