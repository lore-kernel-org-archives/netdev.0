From: Paul Moore <pmoore@redhat.com>
Subject: Re: Problems with VSOCK?
Date: Wed, 20 Feb 2013 17:28:55 -0500
Message-ID: <2319583.NdTBqk4ibZ@sifl>
References: <6456403.c195oTrMFj@sifl> <1906719446.2930546.1361398782879.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: Andy King <acking@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59688 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751166Ab3BTW24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2013 17:28:56 -0500
In-Reply-To: <1906719446.2930546.1361398782879.JavaMail.root@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, February 20, 2013 02:19:42 PM Andy King wrote:
> Hi Paul,
> 
> > I'm currently looking at the VSOCK implementation in netdev-next to
> > determine what we need in the way of LSM hooks and I ran into a few
> > things which look rather odd:
> > 
> > * net/vmw_sock/Kconfig
> > 
> > VMWARE_VMCI_SOCKETS depends on VMWARE_VMCI which doesn't look to be
> > defined
> > anywhere, help?  For what it is worth, removing the VMWARE_VMCI dependency
> 
> Ah, I think this is the same problem someone else had a few days ago.  VMCI
> came in via Greg's char-misc-next tree, and it hasn't merged into Dave's
> tree yet.  But the top-level linux-next tree now has all required modules:
> 
> http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=summary
> 
> Sorry about them coming in from different trees :/

Okay, thanks, I'll grab a copy of the next tree and take a look.  That makes 
much more sense, I was finding it hard to believe that so much was missing :)

-- 
paul moore
security and virtualization @ redhat
