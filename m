From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [E1000-devel] discussion questions: SR-IOV, virtualization, and
 bonding
Date: Thu, 02 Aug 2012 17:15:28 -0600
Message-ID: <501B0A10.8030703@genband.com>
References: <501AD33E.5090308@genband.com> <17679.1343939453@death.nxdomain> <501AFEAD.10001@genband.com> <501B0037.1010804@genband.com> <20421.1343948491@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og124.obsmtp.com ([64.18.2.26]:46916 "EHLO
	exprod7og124.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609Ab2HBXPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 19:15:40 -0400
In-Reply-To: <20421.1343948491@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2012 05:01 PM, Jay Vosburgh wrote:
> Chris Friesen<chris.friesen@genband.com>  wrote:

> 	Still, though, isn't "influence the guest's choice" pretty much
> satisified by having the VF interface go carrier down in the guest when
> the host wants it to?  Or are you thinking about more fine grained than
> that?

That was the first thing we started looking at.

It would actually be better technically (since it would use the 
back-channel between PF and VFs rather than needing an explicit virtual 
network link between host/guest) but it would require work in all the 
PF/VF drivers.  We'd need to get support from all the driver maintainers.

The main advantage of doing it in bonding is that we'd only need to 
modify the code in one place.

Chris
