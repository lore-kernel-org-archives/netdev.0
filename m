From: "David S. Miller" <davem@redhat.com>
Subject: Re: VLAN patches
Date: Sat, 05 Oct 2002 22:05:49 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021005.220549.15266753.davem@redhat.com>
References: <3D9F3D13.3080904@candelatech.com>
	<20021005.211753.25232925.davem@redhat.com>
	<3D9FBCB1.9080904@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Bjorn.Andersson@ebc.ericsson.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3D9FBCB1.9080904@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   Date: Sat, 05 Oct 2002 21:31:45 -0700

   As someone mentioned, vlan of 0 may be used to do a priority-only
   type of VLAN.  I don't know how much this makes sense though...
   
   If we do decide to restrict it, the right place to restrict is in
   the creation clause, not the deletion code, as exists now.

I think we should, please submit a patch which denies it on
both config and delete.

My most recent reading of 802.1q made it very clear that VID 0
is special and should not be assigned to any interface.
