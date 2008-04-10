From: Phil Oester <kernel@linuxace.com>
Subject: Re: bnx2 probe order change from 2.6.21 -> 2.6.24
Date: Thu, 10 Apr 2008 10:54:55 -0700
Message-ID: <20080410175455.GA16754@linuxace.com>
References: <20080410154401.GA14486@linuxace.com> <1207853118.5557.6.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:60445
	"HELO linuxace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756992AbYDJRyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 13:54:55 -0400
Content-Disposition: inline
In-Reply-To: <1207853118.5557.6.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 10, 2008 at 11:45:16AM -0700, Michael Chan wrote:
> On Thu, 2008-04-10 at 08:44 -0700, Phil Oester wrote:
> > I recently upgraded a Dell Poweredge 1950 from 2.6.21 to 2.6.24, and
> > found
> > that the onboard Broadcom NetXtreme II nics got probed in the reverse
> > order.
> 
> I know there is a difference in PCI probing order between 2.4 and 2.6
> kernels on x86 machines, but I'm not aware of changes in these 2 recent
> 2.6 kernels you mentioned above.  Various kernel parameters such as
> pci=nosort, pci=bfsort, pci=nobfsort can affect the order.  Are you
> using any of these?

No - nothing like that.  And the e1000 devices in the box (eth0 - 7) are probing
in the same order, which (perhaps incorrectly) leads me to believe it's not
PCI related, but specific to bnx2.

Phil
