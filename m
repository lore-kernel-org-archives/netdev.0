From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: failure when attempting to build vmci_transport on net-next
Date: Thu, 14 Feb 2013 17:06:15 +0200
Message-ID: <511CFD67.5040505@mellanox.com>
References: <511CB353.3000704@mellanox.com> <1074156873.1496876.1360853681687.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dmitry Torokhov <dtor@vmware.com>,
	George Zhang <georgezhang@vmware.com>
To: Andy King <acking@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:51820 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1760310Ab3BNPG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 10:06:26 -0500
In-Reply-To: <1074156873.1496876.1360853681687.JavaMail.root@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/02/2013 16:54, Andy King wrote:
> Hi Or,
>
>> I didn't manage to get the VMWARE_VMCI_VSOCKETS directive to be set,
>> unless I added the below patch, and
>> once that done got the tons of errors below, am I doing something wrong?
> That's because VMCI, which is necessary for the vSock vmci_transport,
> came in via Greg's char-misc-next tree, and it hasn't yet merged all the
> way over to Dave's net-next tree.

got it, thanks!

Or.

>
> However, I just checked the top-level linux-next tree and it has both,
> so perhaps you could try that instead?
>
> http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=summary
>
> Thanks!
> - Andy
