From: "David S. Miller" <davem@redhat.com>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Mon, 16 Sep 2002 14:04:53 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020916.140453.72638827.davem@redhat.com>
References: <3D860246.3060609@candelatech.com>
	<20020916.125555.36549381.davem@redhat.com>
	<3D8648AE.DD498ECE@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, cacophonix@yahoo.com, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: cfriesen@nortelnetworks.com
In-Reply-To: <3D8648AE.DD498ECE@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Chris Friesen <cfriesen@nortelnetworks.com>
   Date: Mon, 16 Sep 2002 17:10:06 -0400
   
   Okay, that makes me even more curious why we don't send successive
   packets out successive pipes in a bonded link.

This is not done because it leads to packet reordering which
if bad enough can trigger retransmits.

Scott Feldman's posting mentioned this, as did one other I
think.

Same flows (which in this context means TCP connection) must
go over the same link to avoid packet reordering at the receiver.
