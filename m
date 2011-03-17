From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-dev2.6] bxn2x: Fix location of PCI-ids defines
Date: Thu, 17 Mar 2011 10:32:54 -0700
Message-ID: <1300383174.25808.21.camel@HP1>
References: <1300364824.2090.57.camel@lb-tlvb-ariel.il.broadcom.com>
 <20110317.060650.226776465.davem@davemloft.net>
 <1300367613.31873.0.camel@lb-tlvb-eilong.il.broadcom.com>
 <20110317.081046.193692423.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1502 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab1CQRiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 13:38:03 -0400
In-Reply-To: <20110317.081046.193692423.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2011-03-17 at 08:10 -0700, David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Thu, 17 Mar 2011 15:13:33 +0200
> 
> > On Thu, 2011-03-17 at 06:06 -0700, David Miller wrote:
> >> From: "Ariel Elior" <ariele@broadcom.com>
> >> Date: Thu, 17 Mar 2011 14:27:04 +0200
> >> 
> >> > Signed-off-by: Ariel Elior <ariele@broadcom.com>
> >> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> >> 
> >> Unless you intend to reference these symbols elsewhere in the
> >> kernel, they should stay private in your driver.
> >> 
> > 
> > The bnx2i will need it as well. Isn't it better to keep all the PCI IDs
> > in the same global location?
> 
> If they are used in more than one driver, yes.

We already sent a similar patch through the scsi tree.  It is now in the
linux-next tree:

http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commit;h=8a4a0f3ad071e258a9637c5491c34005a9a97903



