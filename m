From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Mon, 16 Sep 2002 17:22:30 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3D864B96.6D0D43F4@nortelnetworks.com>
References: <3D860246.3060609@candelatech.com>
		<20020916.125555.36549381.davem@redhat.com>
		<3D8648AE.DD498ECE@nortelnetworks.com> <20020916.140453.72638827.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, cacophonix@yahoo.com,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
>    From: Chris Friesen <cfriesen@nortelnetworks.com>
> 
>    Okay, that makes me even more curious why we don't send successive
>    packets out successive pipes in a bonded link.
> 
> This is not done because it leads to packet reordering which
> if bad enough can trigger retransmits.
> 
> Scott Feldman's posting mentioned this, as did one other I
> think.

I did see those posts, but then I saw yours on how the linux receive end does the right thing with
regards to reordering, and that confused me.

So if I have it right linux-linux could theoretically work okay with a single stream over multiple
links (potentially causing lots of reordering), but linux-router would not work well.


Chris
