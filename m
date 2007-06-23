From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 18:15:43 -0400
Message-ID: <467D9B8F.2050403@garzik.org>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>	<467CF8AC.80103@trash.net>	<m1bqf6a8rd.fsf@ebiederm.dsl.xmission.com> <20070623.135737.22037347.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, kaber@trash.net, netdev@vger.kernel.org,
	hadi@cyberus.ca, shemminger@linux-foundation.org,
	greearb@candelatech.com, yoshfuji@linux-ipv6.org,
	containers@lists.osdl.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40756 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752575AbXFWWQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 18:16:04 -0400
In-Reply-To: <20070623.135737.22037347.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> I don't accept that we have to add another function argument
> to a bunch of core routines just to support this crap,
> especially since you give no way to turn it off and get
> that function argument slot back.
> 
> To be honest I think this form of virtualization is a complete
> waste of time, even the openvz approach.
> 
> We're protecting the kernel from itself, and that's an endless
> uphill battle that you will never win.  Let's do this kind of
> stuff properly with a real minimal hypervisor, hopefully with
> appropriate hardware level support and good virtualized device
> interfaces, instead of this namespace stuff.

Strongly seconded.  This containerized virtualization approach just 
bloats up the kernel for something that is inherently fragile and IMO 
less secure -- protecting the kernel from itself.

Plenty of other virt approaches don't stir the code like this, while 
simultaneously providing fewer, more-clean entry points for the 
virtualization to occur.

And that's speaking WITHOUT my vendor hat on...

	Jeff


