From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Simultaneous error on two different machines
Date: Wed, 26 Jan 2011 16:52:25 -0800
Message-ID: <1296089545.12935.88.camel@HP1>
References: <4D40BE2A.2010903@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "J.H." <warthog9@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1620 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754413Ab1A0A4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 19:56:41 -0500
In-Reply-To: <4D40BE2A.2010903@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2011-01-26 at 16:36 -0800, J.H. wrote:
> Afternoon,
> 
> Happened to trip over this yesterday on two machines (one an HP DL380 G6
> and one an HP DL 380 G7).  Error was within minutes of each other,
> identical on the two boxes.  Driver seemed to reset (as indicated
> below), however loads on the two boxes almost immediately skyrocketed,
> eventually leading to a more serious deadlock panic on one of the boxes,
> and me just rebooting the other.
> 
> The chipsets involved seem to be:
> 
> Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit
> Ethernet (rev 20)
> 
> Kernel is from Fedora 13, 2.6.34.7-61.korg.fc13.x86_64.  The only
> additional patches applied involve fixing an XFS bug.
> 

Please check if you have this patch in your kernel:

commit c441b8d2cb2194b05550a558d6d95d8944e56a84

    bnx2: Fix lost MSI-X problem on 5709 NICs.





