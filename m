From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [E1000-devel] discussion questions: SR-IOV, virtualization, and
 bonding
Date: Fri, 3 Aug 2012 18:49:23 +0100
Message-ID: <1344016163.2610.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <501AD33E.5090308@genband.com> <17679.1343939453@death.nxdomain>
	 <501AFEAD.10001@genband.com> <501B0037.1010804@genband.com>
	 <20421.1343948491@death.nxdomain> <501B587E.6040703@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Chris Friesen <chris.friesen@genband.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24767 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751716Ab2HCRta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 13:49:30 -0400
In-Reply-To: <501B587E.6040703@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-02 at 21:50 -0700, John Fastabend wrote:
> On 8/2/2012 4:01 PM, Jay Vosburgh wrote:
[...]
> > 	Still, though, isn't "influence the guest's choice" pretty much
> > satisified by having the VF interface go carrier down in the guest when
> > the host wants it to?  Or are you thinking about more fine grained than
> > that?
> >
> 
> Perhaps one argument against this is if the hardware supports loopback
> modes or the edge relay in the hardware is acting like a VEB it may
> still be possible to support VF to VF traffic even if the external link
> is down. Not sure how useful this is though or if any existing hardware
> even supports it.
[...]

It seems to me that VF to VF traffic ought to still work.  If it doesn't
then that's an unfortunate regression when moving from software bridging
and virtio to hardware-supported network virtualisation.  (But hybrid
network virtualisation may help to solve that.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
