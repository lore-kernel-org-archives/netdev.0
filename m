From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: be2net: GRO for non-inet protocols
Date: Tue, 9 Apr 2013 09:55:32 +0200
Message-ID: <20130409075532.GA20363@eerihug-hybrid.ki.sw.ericsson.se>
References: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
 <1365175702.3405.2.camel@edumazet-glaptop>
 <1365175872.3405.3.camel@edumazet-glaptop>
 <20130408064010.GD8543@eerihug-hybrid.ki.sw.ericsson.se>
 <20130408152417.GD19951@eerihug-hybrid.ki.sw.ericsson.se>
 <1365436285.3887.16.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:53709 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935270Ab3DIIAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 04:00:37 -0400
Content-Disposition: inline
In-Reply-To: <1365436285.3887.16.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 08, 2013 at 08:51:25AM -0700, Eric Dumazet wrote:
> On Mon, 2013-04-08 at 17:24 +0200, Erik Hugne wrote:
> > On Mon, Apr 08, 2013 at 08:40:10AM +0200, Erik Hugne wrote:
> > > Thanks Eric, it works as expected after applying this.
> > 
> > So, on to the next problem, now i'm getting corrupted packets
> > from the driver instead. Would be great to get some comments
> > from the Emulex guys regarding this.
> > 
> > Attaching a printk trace where i log the mac header and packet data of 
> > all 0x88CA (TIPC) packets in the gro_receive routine that have an 
> > erroneous TIPC header. This happens immediately when i register 
> > myself with the device.
> > 
> 
> 
> You could check using a GRE tunnel, that the GRO support I added in
> recent kernel is working or not. (including the be2net patch I sent)

I haven't found any issues with the GRO support itself. It's only on
the system with Emulex NIC's that i have problems.
Unfortunately, I'm stuck to kernel 3.0.61 on these machines, newer kernels
won't boot due to an unresolved driver issue with the hw raid controller :/

//E
