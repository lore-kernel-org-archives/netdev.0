From: "David S. Miller" <davem@redhat.com>
Subject: Re: new networking features
Date: Thu, 08 May 2003 09:55:16 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030508.095516.83600195.davem@redhat.com>
References: <3EBA9852.4030808@candelatech.com>
	<20030508.094405.55858508.davem@redhat.com>
	<3EBA9B3D.4050203@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3EBA9B3D.4050203@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   Date: Thu, 08 May 2003 11:00:29 -0700

   Ok, so the general plan would be to add new structs as needed to ethtool.h
   and then extend of the the ethtool enums?
   
There are no enumerations, ethtool commands are merely macro
defines to numbers.  But, otherwise yes.

   Will ethtool ioctls work for generic/virtual interfaces/drivers?

It's all via the devices netdev->do_ioctl(), what is the
problem?
