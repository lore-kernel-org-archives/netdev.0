From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: TOE, etc. (was Re: [PATCH Round 3 0/2][RFC] Network Event Notifier
 Mechanism)
Date: Wed, 28 Jun 2006 00:40:51 -0400
Message-ID: <44A20853.7060406@pobox.com>
References: <20060627205050.30723.25753.stgit@stevo-desktop> <E1FvQBu-00018u-00@gondolin.me.apana.org.au> <20060628030400.GA4474@gondor.apana.org.au> <44A1F669.8070606@pobox.com> <20060628033708.GA4922@gondor.apana.org.au> <44A20311.5050301@pobox.com> <20060628042959.GA5561@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Steve Wise <swise@opengridcomputing.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:3504 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1423041AbWF1Ek6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 00:40:58 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060628042959.GA5561@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Wed, Jun 28, 2006 at 12:18:25AM -0400, Jeff Garzik wrote:
>> A PCI device that presents itself as a SCSI controller, but under the 
>> hood is really iSCSI-over-TCP smells like TOE.  Running a virtualized 
>> Linux guest on top of a proprietary stack [which provides networking 
>> services to guests] also smells like TOE.  :)
> 
> Agreed.  However, when they start adding hooks to the ARP table, the
> routing table, and PMTU management, it begs the question what more is
> there to add for TOE (well, user-space driven TOE at least)?

Well, you've always been able to implement userspace (or otherwise 
completely-virtualized) network stack.  tuntap and the packet socket 
enable that, if nothing else.  But, like you characterize below, those 
are existing, well-defined, easily contained interfaces.


> Put it another way, I think the dividing line between TOE and iSCSI or
> virtualisation is exactly the interface between them and the Linux kernel.
> If the interface is an existing one such as SCSI or standard IP then it's
> OK.  However, when it starts poking in the guts of the Linux stack I'd say
> that it has crossed the line.

Strongly agreed.

	Jeff


