From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Fri, 29 Dec 2006 03:04:06 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0612290255501.12445@bizon.gios.gov.pl>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
 <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
 <1167046499.3281.1623.camel@laptopd505.fenrus.org>
 <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
 <1167158658.3746.12.camel@localhost>  <1167170793.3281.3209.camel@laptopd505.fenrus.org>
  <1167173199.3746.45.camel@localhost>  <1167179309.3281.3342.camel@laptopd505.fenrus.org>
  <1167191279.3746.60.camel@localhost>  <7e63f56c0612262309p5337a753q3b1748910fce70b5@mail.gmail.com>
 <1167229879.3807.24.camel@localhost>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1354432153-1167357846=:12445"
Cc: Robert Iakobashvili <coroberti@gmail.com>,
	Arjan van de Ven <arjan@infradead.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:56709 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755044AbWL2CbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Dec 2006 21:31:21 -0500
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1167229879.3807.24.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1354432153-1167357846=:12445
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Wed, 27 Dec 2006, jamal wrote:

> On Wed, 2006-27-12 at 09:09 +0200, Robert Iakobashvili wrote:
>
>>
>> My scenario is treatment of RTP packets in kernel space with a single ne=
twork
>> card (both Rx and Tx). The default of the Intel 5000 series chipset is
>> affinity of each
>> network card to a certain CPU. Currently, neither with irqbalance nor
>> with kernel
>> irq-balancing (MSI and io-apic attempted) I do not find a way to
>> balance that irq.
>
> In the near future, when the NIC vendors wake up[1] because CPU vendors
> - including big bad Intel -  are going to be putting out a large number
> of hardware threads, you should be able to do more clever things with
> such a setup. At the moment, just tie it to a single CPU and have your
> other processes that are related running/bound on the other cores so you
> can utilize them. OTOH, you say you are only using 30% of the one CPU,
> so it may not be a big deal to tie your single nic to on cpu.

Anyway, it seems that with more advanced firewalls/routers kernel spends=20
most of a time in IPSec/crypto code, netfilter conntrack and iptables=20
rules/extensions, routing lookups, etc and not in hardware IRQ handler.=20
So, it would be nice if this part coulde done by all CPUs.

Best regards,


 =09=09=09Krzysztof Ol=EAdzki
---187430788-1354432153-1167357846=:12445--
