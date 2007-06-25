From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Mon, 25 Jun 2007 10:11:51 -0500
Message-ID: <20070625151151.GA19546@sergelap.austin.ibm.com>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com> <467CF8AC.80103@trash.net> <m1bqf6a8rd.fsf@ebiederm.dsl.xmission.com> <20070623.135737.22037347.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, jeff@garzik.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, hadi@cyberus.ca, containers@lists.osdl.org,
	greearb@candelatech.com, shemminger@linux-foundation.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:43166 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755543AbXFYPRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 11:17:44 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5PFHiNF014194
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 11:17:44 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5PFGLGj062984
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 09:17:43 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5PFBq3M002884
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 09:11:53 -0600
Content-Disposition: inline
In-Reply-To: <20070623.135737.22037347.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting David Miller (davem@davemloft.net):
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Sat, 23 Jun 2007 11:19:34 -0600
> 
> > Further and fundamentally all a global achieves is removing the need
> > for the noise patches where you pass the pointer into the various
> > functions.  For long term maintenance it doesn't help anything.
> 
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

Hi David,

just to be clear this isn't so much about security.  Security can be
provided using selinux, just as with the userid namespace.  But like
with the userid namespace, this provides usability for the virtual
servers, plus some support for restarting checkpointed applications.

That doesn't attempt to justify the extra argument - if you don't
like it, you don't like it  :)  Just wanted to clarify.

thanks,
-serge

> stuff properly with a real minimal hypervisor, hopefully with
> appropriate hardware level support and good virtualized device
> interfaces, instead of this namespace stuff.
> 
> At least the hypervisor approach you have some chance to fully
> harden in some verifyable and truly protected way, with
> namespaces it's just a pipe dream and everyone who works on
> these namespace approaches knows that very well.
> 
> The only positive thing that came out of this work is the
> great auditing that the openvz folks have done and the bugs
> they have found, but it basically ends right there.
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
