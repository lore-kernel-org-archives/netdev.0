From: Andy King <acking@vmware.com>
Subject: Re: failure when attempting to build vmci_transport on net-next
Date: Thu, 14 Feb 2013 06:54:41 -0800 (PST)
Message-ID: <1074156873.1496876.1360853681687.JavaMail.root@vmware.com>
References: <511CB353.3000704@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dmitry Torokhov <dtor@vmware.com>,
	George Zhang <georgezhang@vmware.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:58771 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759953Ab3BNOym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 09:54:42 -0500
In-Reply-To: <511CB353.3000704@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Or,

> I didn't manage to get the VMWARE_VMCI_VSOCKETS directive to be set,
> unless I added the below patch, and
> once that done got the tons of errors below, am I doing something wrong?

That's because VMCI, which is necessary for the vSock vmci_transport,
came in via Greg's char-misc-next tree, and it hasn't yet merged all the
way over to Dave's net-next tree.

However, I just checked the top-level linux-next tree and it has both,
so perhaps you could try that instead?

http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=summary

Thanks!
- Andy
