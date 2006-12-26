From: jamal <hadi@cyberus.ca>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Tue, 26 Dec 2006 13:44:18 -0500
Message-ID: <1167158658.3746.12.camel@localhost>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
	 <1167046499.3281.1623.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:40683 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932750AbWLZSoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Dec 2006 13:44:22 -0500
Received: by wx-out-0506.google.com with SMTP id h27so3943594wxd
        for <netdev@vger.kernel.org>; Tue, 26 Dec 2006 10:44:21 -0800 (PST)
To: Robert Iakobashvili <coroberti@gmail.com>
In-Reply-To: <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


If you compile in PCI-E support you should have more control of the
MSI-X, no? I would tie the MSI to a specific processor statically; my
past experiences with any form of interupt balancing with network loads
has been horrible.

cheers,
jamal

On Mon, 2006-25-12 at 14:54 +0200, Robert Iakobashvili wrote:
> Arjan,
> 
> On 12/25/06, Arjan van de Ven <arjan@infradead.org> wrote:
> > On Mon, 2006-12-25 at 13:26 +0200, Robert Iakobashvili wrote:
> > >
> >
> > it can still be done using the TPR (Thread Priority Register) of the
> > APIC. It's just... not there in Linux (other OSes do use this).
> 
> Interesting.
> Have you any specific pointers for doing it (beyond Internet search)?
> Your input would be very much appreciated.
> Thank you.
> 
> 

