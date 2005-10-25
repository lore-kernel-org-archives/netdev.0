From: "Ayaz Abdulla" <AAbdulla@nvidia.com>
Subject: RE: [PATCH 2/2] forcedeth: scatter gather and segmentation offload support
Date: Tue, 25 Oct 2005 14:15:49 -0700
Message-ID: <DBFABB80F7FD3143A911F9E6CFD477B00BA5D790@hqemmail02.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
        "Manfred Spraul" <manfred@colorfullife.com>,
        "Netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

We give the fragments in that order to ensure they are all setup before
hardware starts looking at them.

I can fix up the coding style issue in another patch. That has been
there since day 1 and is not related to this patch.

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@osdl.org] 
Sent: Monday, October 24, 2005 2:21 PM
To: Ayaz Abdulla
Cc: Jeff Garzik; Manfred Spraul; Netdev
Subject: Re: [PATCH 2/2] forcedeth: scatter gather and segmentation
offload support


On Mon, 24 Oct 2005 12:48:07 -0400
Ayaz Abdulla <aabdulla@nvidia.com> wrote:

> Jeff,
> 
> I made the changes you requested. Here is the new patch.
> 
> Thanks,
> Ayaz
> 
> Signed-off-By: Ayaz Abdulla <aabdulla@nvidia.com>
> 

There are really three patches in here.
	1. Use netdev_priv (trivial)
	2. scatter/gather support
	3. TSO support

Why do you set the fragments up in reverse order? Going backwards is
usually slow on most code.

The kernel coding style is to use lower case in local variable names
(Flags)
and structure elements (PacketBuffer, FlagLen). 

-- 
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger
