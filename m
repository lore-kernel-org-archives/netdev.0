From: "David S. Miller" <davem@redhat.com>
Subject: Re: VLAN patches
Date: Sat, 05 Oct 2002 21:17:53 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021005.211753.25232925.davem@redhat.com>
References: <3D980A10.8B06F2C2@ebc.ericsson.se>
	<3D9F3D13.3080904@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Bjorn.Andersson@ebc.ericsson.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3D9F3D13.3080904@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   Date: Sat, 05 Oct 2002 12:27:15 -0700

   This patch looks good too, though the (vlan_id < 0) test
   is redundant since vlan_id is an unsigned number.  For
   clarity of code, I wouldn't mind if it stayed in though.
   
VLAN ID zero is illegal.  You should not use ifconfig
with a VID of zero.
