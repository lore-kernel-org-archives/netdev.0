From: Ben Greear <greearb@candelatech.com>
Subject: Re: VLAN patches
Date: Sat, 05 Oct 2002 21:31:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D9FBCB1.9080904@candelatech.com>
References: <3D980A10.8B06F2C2@ebc.ericsson.se>	<3D9F3D13.3080904@candelatech.com> <20021005.211753.25232925.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bjorn.Andersson@ebc.ericsson.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Ben Greear <greearb@candelatech.com>
>    Date: Sat, 05 Oct 2002 12:27:15 -0700
> 
>    This patch looks good too, though the (vlan_id < 0) test
>    is redundant since vlan_id is an unsigned number.  For
>    clarity of code, I wouldn't mind if it stayed in though.
>    
> VLAN ID zero is illegal.  You should not use ifconfig
> with a VID of zero.
> 

As someone mentioned, vlan of 0 may be used to do a priority-only
type of VLAN.  I don't know how much this makes sense though...

If we do decide to restrict it, the right place to restrict is in
the creation clause, not the deletion code, as exists now.

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
