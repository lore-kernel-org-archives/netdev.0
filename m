From: Andy Gospodarek <gospo@redhat.com>
Subject: Re: 802.1D/Linux STP issue
Date: Thu, 14 Sep 2006 17:21:43 -0400
Message-ID: <20060914212142.GB12665@gospo.rdu.redhat.com>
References: <OF1AE42FF9.06C5D926-ON852571E7.005804CC-852571E7.0057EE7E@ieee.org> <45076B88.80104@bristyle.com> <6.0.1.1.2.20060913075410.04133280@mail.expressoweb.co.uk> <45088D29.30501@bristyle.com> <20060914100619.76cb1828@localhost.localdomain> <6.0.1.1.2.20060914174624.05055480@mail.expressoweb.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Brian Braunstein <brian@bristyle.com>,
	Rajesh Mishra <rajesh_mish@yahoo.com>, bridge@osdl.org,
	netdev@vger.kernel.org, mick_seaman@ieee.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:22215 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751178AbWINVVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 17:21:51 -0400
To: Tony Jeffree <tony@jeffree.co.uk>
Content-Disposition: inline
In-Reply-To: <6.0.1.1.2.20060914174624.05055480@mail.expressoweb.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 14, 2006 at 05:51:50PM +0100, Tony Jeffree wrote:
> Steve/Brian -
> 
> You've probably seen Mick Seaman's comments on this by now - as he points 
> out in his email, tinkering with existing STP implementations is not likely 
> to be a rewarding exercise and I would encourage you not to go there.
> 
> I would suggest that it would be a much more valuable exercise for the 
> Linux community to replace the existing STP support with an implementation 
> of RSTP.
> 

While we are at it can we rip it out of the kernel and develop a
user-space daemon that does it instead?  Setting the spanning-tree state
of a port could be done with a simple ioctl (well not too simple because
it would be good to support multiple STP instances so someone could
code up 802.1w support and the kernel interface would already be there).

Thoughts?


