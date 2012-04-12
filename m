From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] net: smsc911x: fix RX FIFO fastforwarding when dropping
 packets
Date: Thu, 12 Apr 2012 18:03:50 +0100
Message-ID: <20120412170350.GD28204@mudshark.cambridge.arm.com>
References: <1334221644-16056-1-git-send-email-will.deacon@arm.com>
 <1334222448.5300.6046.camel@edumazet-glaptop>
 <20120412125355.GG16025@mudshark.cambridge.arm.com>
 <1334235963.5300.6361.camel@edumazet-glaptop>
 <20120412134757.GH16025@mudshark.cambridge.arm.com>
 <1334239299.5300.6478.camel@edumazet-glaptop>
 <20120412155409.GA28204@mudshark.cambridge.arm.com>
 <1334246880.5300.6736.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:63544 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752170Ab2DLRDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 13:03:54 -0400
Content-Disposition: inline
In-Reply-To: <1334246880.5300.6736.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 12, 2012 at 05:08:00PM +0100, Eric Dumazet wrote:
> On Thu, 2012-04-12 at 16:54 +0100, Will Deacon wrote:
> >     net: smsc911x: fix skb handling in receive path
> >     
> >     The SMSC911x driver resets the ->head, ->data and ->tail pointers in the
> >     skb on the reset path in order to avoid buffer overflow due to packet
> >     padding performed by the hardware.
> >     
> >     This patch fixes the receive path so that the skb pointers are fixed up
> >     after the data has been read from the device, The error path is also
> >     fixed to use number of words consistently and prevent erroneous FIFO
> >     fastforwarding when skipping over bad data.
> >     
> >     Signed-off-by: Will Deacon <will.deacon@arm.com>

[...]

> Seems fine to me
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks, Eric. Given that Steve's email doesn't appear to be working, can
somebody else pick this up please?

Cheers,

Will
