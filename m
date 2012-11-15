From: Anthony Liguori <aliguori@us.ibm.com>
Subject: Re: [Pv-drivers] [PATCH 0/6] VSOCK for Linux upstreaming
Date: Thu, 15 Nov 2012 15:32:07 -0600
Message-ID: <50A55F57.7080804@us.ibm.com>
References: <783561822.12637564.1352139592543.JavaMail.root@vmware.com> <509A06AB.2020700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy King <acking@vmware.com>, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, David Miller <davem@davemloft.net>,
	georgezhang@vmware.com,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:43221 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050Ab2KOVcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 16:32:19 -0500
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <aliguori@us.ibm.com>;
	Fri, 16 Nov 2012 03:02:16 +0530
In-Reply-To: <509A06AB.2020700@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2012 12:58 AM, Gerd Hoffmann wrote:
> On 11/05/12 19:19, Andy King wrote:
>> Hi David,
>>
>>> The big and only question is whether anyone can actually use any of
>>> this stuff without your proprietary bits?
>>
>> Do you mean the VMCI calls?  The VMCI driver is in the process of being
>> upstreamed into the drivers/misc tree.  Greg (cc'd on these patches) is
>> actively reviewing that code and we are addressing feedback.
>>
>> Also, there was some interest from RedHat into using vSockets as a unified
>> interface, routed over a hypervisor-specific transport (virtio or
>> otherwise, although for now VMCI is the only one implemented).
>
> Can you outline how this can be done?  From a quick look over the code
> it seems like vsock has a hard dependency on vmci, is that correct?
>
> When making vsock a generic, reusable kernel service it should be the
> other way around:  vsock should provide the core implementation and an
> interface where hypervisor-specific transports (vmci, virtio, xenbus,
> ...) can register themself.

This was already done in a hypervisor neutral way using virtio:

http://lists.openwall.net/netdev/2008/12/14/8

The concept was Nacked and that led to the abomination of virtio-serial.  If an 
address family for virtualization is on the table, we should reconsider 
AF_VMCHANNEL.

I'd be thrilled to get rid of virtio-serial...

Regards,

Anthony Liguori

>
> cheers,
>    Gerd
