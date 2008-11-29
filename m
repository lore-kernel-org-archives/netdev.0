From: Raz <raziebe@gmail.com>
Subject: Re: what is the expeted performance from a dual port 10G card ?
Date: Sat, 29 Nov 2008 10:11:54 +0200
Message-ID: <5d96567b0811290011u58f4c9bj93d6c781b67b91ad@mail.gmail.com>
References: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com>
	 <4930E183.9040700@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Divy Le Ray" <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:65485 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbYK2ILz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 03:11:55 -0500
Received: by yx-out-2324.google.com with SMTP id 8so674504yxm.1
        for <netdev@vger.kernel.org>; Sat, 29 Nov 2008 00:11:54 -0800 (PST)
In-Reply-To: <4930E183.9040700@chelsio.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 29, 2008 at 8:30 AM, Divy Le Ray <divy@chelsio.com> wrote:
> Raz wrote:
>> Hello
>> I have been testing 10G ethernet cards , intel ixgbe, chelsio, tehuti
>> and melanox . All are dual port cards.
>> I have used pktgen to test it. A single cpu is mapped over a single
>> interface (no neeed for MQ , which is quite bad anyway).
>> Results:
>> Intel gives: 13Gbps , 6.5 from each port.
>> The rest give ~10 Gbps .
>> Cards were tested on PCI-E x8 slot, on a supermicro x7DBI and
>> supermicro 1025W-UR.
>>
>> Am i to expect ~20Gbps from each card ?
>
> Hi Raz,
>
> For the rest, what is the load balance between the ports?
> The Chelsio adapter shares the pci link between all ports.
>
> Cheers,
> Divy
>
All ports share the same bandwidth. in chelsio it is 4.8 Gbps from each port.
