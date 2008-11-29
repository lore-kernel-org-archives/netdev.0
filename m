From: Raz <raziebe@gmail.com>
Subject: Re: what is the expeted performance from a dual port 10G card ?
Date: Sat, 29 Nov 2008 10:10:37 +0200
Message-ID: <5d96567b0811290010r641388b7w179bc4af26bbf103@mail.gmail.com>
References: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com>
	 <20081128135419.GH32518@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:24622 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbYK2IKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 03:10:39 -0500
Received: by an-out-0708.google.com with SMTP id d40so623197and.1
        for <netdev@vger.kernel.org>; Sat, 29 Nov 2008 00:10:38 -0800 (PST)
In-Reply-To: <20081128135419.GH32518@solarflare.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI Encoding overhead is 8 bits /10 bits . so 16Gbps supposed to be
the practical limit. I still lack 3 Gbps in the Intel case.
where are they ?

On Fri, Nov 28, 2008 at 3:54 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
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
> PCI Express provides 2.5 Gbps per lane (can be 5 Gbps in PCIe 2.0 but
> that's quite new).  So an x8 slot is limited to 20 Gbps including all
> the PCIe protocol overhead, which can be substantial.  You will not
> get 20 Gbps out of dual-port cards without doubling the width or lane
> speed.
>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
