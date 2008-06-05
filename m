From: David Dillow <dillowda@ornl.gov>
Subject: Re: [ofa-general] Re: [PATCH v3 08/13] QLogic VNIC: sysfs	interface
 implementation for the driver
Date: Thu, 05 Jun 2008 13:54:46 -0400
Message-ID: <1212688486.1173.5.camel@lap75545.ornl.gov>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>
 <20080529095754.9943.27936.stgit@localhost.localdomain>
 <20080529103003.010c4a08@extreme> <20080529174805.GA10903@kroah.com>
 <c8028d330806031125x4181d8e3p9cdaf1f4c79e88c6@mail.gmail.com>
 <1212518703.2217.22.camel@lap75545.ornl.gov> <aday75k1pzh.fsf@cisco.com>
 <20080605054035.GA8059@ornl.gov> <adazlpzzvjn.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Amar Mudrankit <amar.mudrankit@qlogic.com>,
	Greg KH <greg@kroah.com>, general@lists.openfabrics.org,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	poornima.kamath@qlogic.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emroute3.ornl.gov ([160.91.4.110]:33057 "EHLO emroute3.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752225AbYFERyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 13:54:47 -0400
Received: from emroute3.ornl.gov ([127.0.0.1])
 by emroute3.ornl.gov (PMDF V6.3-x14 #31501)
 with ESMTP id <0K2000C584FA95@emroute3.ornl.gov> for netdev@vger.kernel.org;
 Thu, 05 Jun 2008 13:54:46 -0400 (EDT)
In-reply-to: <adazlpzzvjn.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-06-05 at 09:38 -0700, Roland Dreier wrote:
> > That said, given that SRP's been using sysfs since it went in, is there
>  > a reason to move to configfs other than it's the new preferred way to do
>  > it? Given the desire to not break ABI's -- and IIRC sysfs was declared to
>  > be under that unbrella -- wouldn't we have to at least carry both
>  > interfaces for a while, assuming we can even get rid of the sysfs one?
> 
> Yes, we'd definitely be carrying both interfaces for at least a year.
> 
> Looking further into this, I'm not sure it makes much sense either.
> Another problem with configfs is that the lifetime of the object is
> controlled by userspace.  So if we lose a connection to a target,
> the object will persist in configfs until userspace notices.

Yep. Though I'd like to be able to have a persistent connection and
retry capability in the kernel, so that I don't need to have srp_daemon,
and the persistence would be fine in that case. I've not fully convinced
myself that doing a persistent connection in the kernel is a good idea,
but a deep background task is trying to do the OFED patches to the
initiator in a way that is acceptable for inclusion in mainline, and
they would easily fall out of that work.
-- 
Dave Dillow
National Center for Computational Science
Oak Ridge National Laboratory
(865) 241-6602 office


