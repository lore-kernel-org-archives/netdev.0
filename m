From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [E1000-devel] discussion questions: SR-IOV, virtualization, and
 bonding
Date: Fri, 10 Aug 2012 12:41:40 -0600
Message-ID: <502555E4.6060705@genband.com>
References: <501AD33E.5090308@genband.com> <17679.1343939453@death.nxdomain>	 <501AFEAD.10001@genband.com> <501B0037.1010804@genband.com>	 <20421.1343948491@death.nxdomain> <501B587E.6040703@intel.com> <1344016163.2610.9.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og121.obsmtp.com ([64.18.2.20]:40350 "EHLO
	exprod7og121.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754673Ab2HJSl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 14:41:58 -0400
In-Reply-To: <1344016163.2610.9.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2012 11:49 AM, Ben Hutchings wrote:
> On Thu, 2012-08-02 at 21:50 -0700, John Fastabend wrote:

>> Perhaps one argument against this is if the hardware supports loopback
>> modes or the edge relay in the hardware is acting like a VEB it may
>> still be possible to support VF to VF traffic even if the external link
>> is down. Not sure how useful this is though or if any existing hardware
>> even supports it.
> [...]
>
> It seems to me that VF to VF traffic ought to still work.  If it doesn't
> then that's an unfortunate regression when moving from software bridging
> and virtio to hardware-supported network virtualisation.  (But hybrid
> network virtualisation may help to solve that.)

I would have thought this to be desirable as well.  Apparently the Intel 
engineers disagreed.  The 82599 datasheet has the following:

"Loopback is disabled when the network link is disconnected. It is 
expected (but not required) that system software (including VMs) does 
not post packets for transmission when the link is disconnected. Note 
that packets posted by system software for transmission when the link is 
down are buffered."

Chris
