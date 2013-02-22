From: Andy King <acking@vmware.com>
Subject: Re: AF_VSOCK and the LSMs
Date: Fri, 22 Feb 2013 14:54:43 -0800 (PST)
Message-ID: <888679886.3769933.1361573683299.JavaMail.root@vmware.com>
References: <1803195.0cVPJuGAEx@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, Gerd Hoffmann <kraxel@redhat.com>,
	Eric Paris <eparis@redhat.com>
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:51089 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754218Ab3BVWyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 17:54:44 -0500
In-Reply-To: <1803195.0cVPJuGAEx@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul,

> to see if anyone had any strong feelings on this approach (either good or
> bad).  Here is what I am proposing, and currently working on ...
> 
> * Add a LSM secid/blob to the vmci_datagram struct

I think perhaps this is the wrong layer at which to embed this.  Think
of that structure as an ethernet header, with VMCI being ethernet; it's
what the device (and the hypervisor and peer) understand.  So this
really cannot be changed.

It's also not entirely clear to me how this will work in a heterogeneous
environments.  What if there's a Linux guest running on a Windows host,
or vice-versa?

I'll take a closer read at the rest of your mail, but I think we need to
address the above first.

Thanks!
- Andy
