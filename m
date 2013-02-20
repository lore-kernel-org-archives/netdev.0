From: Andy King <acking@vmware.com>
Subject: Re: Problems with VSOCK?
Date: Wed, 20 Feb 2013 14:19:42 -0800 (PST)
Message-ID: <1906719446.2930546.1361398782879.JavaMail.root@vmware.com>
References: <6456403.c195oTrMFj@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:51981 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750923Ab3BTWTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 17:19:43 -0500
In-Reply-To: <6456403.c195oTrMFj@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul,

> I'm currently looking at the VSOCK implementation in netdev-next to determine
> what we need in the way of LSM hooks and I ran into a few things which look
> rather odd:
> 
> * net/vmw_sock/Kconfig
> 
> VMWARE_VMCI_SOCKETS depends on VMWARE_VMCI which doesn't look to be defined
> anywhere, help?  For what it is worth, removing the VMWARE_VMCI dependency

Ah, I think this is the same problem someone else had a few days ago.  VMCI
came in via Greg's char-misc-next tree, and it hasn't merged into Dave's
tree yet.  But the top-level linux-next tree now has all required modules:

http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=summary

Sorry about them coming in from different trees :/

Thanks!
- Andy
