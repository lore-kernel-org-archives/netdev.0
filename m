From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Tue, 26 Dec 2006 21:51:31 +0200
Message-ID: <7e63f56c0612261151y7aa95954hb2a1d47ce130c38d@mail.gmail.com>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
	 <1167046499.3281.1623.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
	 <1167158658.3746.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Arjan van de Ven" <arjan@infradead.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:39769 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932765AbWLZTvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Dec 2006 14:51:33 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4927106nfa
        for <netdev@vger.kernel.org>; Tue, 26 Dec 2006 11:51:32 -0800 (PST)
To: hadi@cyberus.ca
In-Reply-To: <1167158658.3746.12.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/26/06, jamal <hadi@cyberus.ca> wrote:
>
> If you compile in PCI-E support you should have more control of the
> MSI-X, no? I would tie the MSI to a specific processor statically; my
> past experiences with any form of interupt balancing with network loads
> has been horrible.
>
> cheers,
> jamal

Thanks for the direction.

In meanwhile I have removed all userland processes from CPU0,
that handles network card interrupts and all packet-processing (kernel-space).

Still, it should be some way of CPU-scaling; even for the case of the
only network
card.


> > >
> > > it can still be done using the TPR (Thread Priority Register) of the
> > > APIC. It's just... not there in Linux (other OSes do use this).
> >
> > Have you any specific pointers for doing it (beyond Internet search)?
> > Your input would be very much appreciated.



-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...................................................................
Navigare necesse est, vivere non est necesse
...................................................................
http://sourceforge.net/projects/curl-loader
A powerful open-source HTTP/S, FTP/S traffic
generating, loading and testing tool.
