From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 probe order change from 2.6.21 -> 2.6.24
Date: Thu, 10 Apr 2008 12:15:50 -0700
Message-ID: <1207854953.5248.2.camel@dell>
References: <20080410154401.GA14486@linuxace.com>
 <1207853118.5557.6.camel@dell> <20080410175455.GA16754@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Phil Oester" <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3280 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758813AbYDJSXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 14:23:06 -0400
In-Reply-To: <20080410175455.GA16754@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-04-10 at 10:54 -0700, Phil Oester wrote:
> On Thu, Apr 10, 2008 at 11:45:16AM -0700, Michael Chan wrote:
> > I know there is a difference in PCI probing order between 2.4 and 2.6
> > kernels on x86 machines, but I'm not aware of changes in these 2 recent
> > 2.6 kernels you mentioned above.  Various kernel parameters such as
> > pci=nosort, pci=bfsort, pci=nobfsort can affect the order.  Are you
> > using any of these?
> 
> No - nothing like that.  And the e1000 devices in the box (eth0 - 7) are probing
> in the same order, which (perhaps incorrectly) leads me to believe it's not
> PCI related, but specific to bnx2.
> 

The driver has no control over the ordering of these devices.  The PCI
layer scans the buses in the order it chooses and calls the driver's
probe method for every matching device that it finds.

