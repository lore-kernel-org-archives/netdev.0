From: Ben Greear <greearb@candelatech.com>
Subject: Re: Problems using bonding with vlan
Date: Mon, 15 Sep 2003 09:58:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F65EFCB.5050500@candelatech.com>
References: <200309151632.59915.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com,
   amir.noam@intel.com, tsippy.mendelson@intel.com, naom.marom@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: <200309151632.59915.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Shmulik Hen wrote:

> I think we should add to the 8021q module the ability to listen to 
> netdev events and to set it's hardware address whenever the 
> underlying device changes it own, instead of just during the VLAN 
> interface creation.

One can also change the VLAN MAC address at any time with 'ip' or 'ifconfig',
just like regular ethernet devices.  So, the startup script could easily rectify
things if needed (VLAN device will put it's underlying device into promisc or multicast
mode if needed).

The VLAN code does listen for net-events already, so if you wanted to change
when the VLAN MAC is 0:0....0, then that might be friendlier to the user, but
please do NOT change the MAC if it is already set to something non zero.

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
