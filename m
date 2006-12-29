From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Fri, 29 Dec 2006 19:36:19 +0200
Message-ID: <7e63f56c0612290936n25186dc1sd96f32bacbb5a674@mail.gmail.com>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
	 <1167158658.3746.12.camel@localhost>
	 <1167170793.3281.3209.camel@laptopd505.fenrus.org>
	 <1167173199.3746.45.camel@localhost>
	 <1167179309.3281.3342.camel@laptopd505.fenrus.org>
	 <1167191279.3746.60.camel@localhost>
	 <7e63f56c0612262309p5337a753q3b1748910fce70b5@mail.gmail.com>
	 <1167229879.3807.24.camel@localhost>
	 <Pine.LNX.4.64.0612290255501.12445@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "Arjan van de Ven" <arjan@infradead.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:19508 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965027AbWL2RgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Dec 2006 12:36:21 -0500
Received: by ug-out-1314.google.com with SMTP id 44so4441179uga
        for <netdev@vger.kernel.org>; Fri, 29 Dec 2006 09:36:20 -0800 (PST)
To: "Krzysztof Oledzki" <olel@ans.pl>
In-Reply-To: <Pine.LNX.4.64.0612290255501.12445@bizon.gios.gov.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Krzysztof,

On 12/29/06, Krzysztof Oledzki <olel@ans.pl> wrote:
>
>
> On Wed, 27 Dec 2006, jamal wrote:
>
> > On Wed, 2006-27-12 at 09:09 +0200, Robert Iakobashvili wrote:
> >
> >>
> >> My scenario is treatment of RTP packets in kernel space with a single network
> >> card (both Rx and Tx). The default of the Intel 5000 series chipset is
> >> affinity of each
> >> network card to a certain CPU. Currently, neither with irqbalance nor
> >> with kernel
> >> irq-balancing (MSI and io-apic attempted) I do not find a way to
> >> balance that irq.
> >
> > In the near future, when the NIC vendors wake up[1] because CPU vendors
> > - including big bad Intel -  are going to be putting out a large number
> > of hardware threads, you should be able to do more clever things with
> > such a setup. At the moment, just tie it to a single CPU and have your
> > other processes that are related running/bound on the other cores so you
> > can utilize them. OTOH, you say you are only using 30% of the one CPU,
> > so it may not be a big deal to tie your single nic to on cpu.
>
> Anyway, it seems that with more advanced firewalls/routers kernel spends
> most of a time in IPSec/crypto code, netfilter conntrack and iptables
> rules/extensions, routing lookups, etc and not in hardware IRQ handler.
> So, it would be nice if this part coulde done by all CPUs.


Do you mean, that it should be an option to configure BH soft-irq handling
to make packet processing balanced among several CPUs?
There is an issue of packet order, isn't it?


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
