From: Lewis Adam-CAL022 <Adam.Lewis@motorola.com>
Subject: RE: hard_start_xmit and Linux bridging
Date: Fri, 10 Sep 2004 10:24:10 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <FD52892BD296D71183B400065BFCB6900EE98AA3@il02exm12>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>,
        Lewis Adam-CAL022
	 <Adam.Lewis@motorola.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi Ben,

> -----Original Message-----
> From: Ben Greear [mailto:greearb@candelatech.com] 
> Sent: Thursday, September 09, 2004 6:30 PM
> To: Lewis Adam-CAL022
> Cc: netdev@oss.sgi.com
> Subject: Re: hard_start_xmit and Linux bridging
> 
> I added some ioctls to allow one to turn on the ability to 
> receive the CRC, but I don't know of any drivers that include 
> it by default.

Right, this is what I would have expected since no other driver account for it.

> 
> What driver/hardware is your eth0 device?

It is a custom board but a Xilinx PCORE and using a Montavista driver.  Based on what you said above, it seems that I might want to pursue this with them.

> 
> How are you determining the size, by the skb->len ?

Exactly.  And not only does it include the FCS/CRC, but in the case of an ARP, there are an extra 14 trailing 0's.  I thought this was a bridging issue, now I'm thinking it's a xilinx/mvista issue.

> 
> Does tcpdump/ethereal show the extra 4 bytes if you sniff 
> eth0 w/out bridging?

Yeah.  And in the case of ARP it is even weirder, and extra 18 bytes, mostly zeros.  So case in point, it sounds like this is not proper operation?  I want to confirm before I bring it up with Xilinx and Montavista.

Thanks!
Adam
