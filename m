From: Ben Greear <greearb@candelatech.com>
Subject: Re: new networking features
Date: Thu, 08 May 2003 11:00:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EBA9B3D.4050203@candelatech.com>
References: <3EBA9852.4030808@candelatech.com> <20030508.094405.55858508.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030508.094405.55858508.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Independant of whether I'm interested in the changes, please use
> ethtool in deference to ioctls.  If you absolutely must use
> ioctls, I can't accept the changes without updates to the
> compatability layer ioctl translation code of every platform.
> 

Ok, so the general plan would be to add new structs as needed to ethtool.h
and then extend of the the ethtool enums?

Will ethtool ioctls work for generic/virtual interfaces/drivers?  I
need some way to get hooks into specific (ie dev.c, vlan, macvlan) code,
but I'm not too particular about how it gets there as long as it
isn't netlink :)

Also, for the VLAN code, it's not really adding a new ioctl, but adding a new
enum value to an existing ioctl payload...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
