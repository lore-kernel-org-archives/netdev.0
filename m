From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC net-next 0/3] Proposal for VRF-lite
Date: Tue, 09 Jun 2015 10:58:58 +0200
Message-ID: <5576AAD2.8010405@6wind.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	hannes@stressinduktion.org, dsahern@gmail.com,
	ebiederm@xmission.com, hadi@mojatatu.com, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35571 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025AbbFII7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 04:59:02 -0400
Received: by wiga1 with SMTP id a1so9222093wig.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 01:59:01 -0700 (PDT)
In-Reply-To: <cover.1433561681.git.shm@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/06/2015 20:35, Shrijeet Mukherjee a =C3=A9crit :
> From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
>
> In the context of internet scale routing a requirement that always
> comes up is the need to partition the available routing tables into
> disjoint routing planes. A specific use case is the multi-tenancy
> problem where each tenant has their own unique routing tables and in
> the very least need different default gateways.
>
> This is an attempt to build the ability to create virtual router
> domains aka VRF's (VRF-lite to be specific) in the linux packet
> forwarding stack. The main observation is that through the use of
[snip]
>   drivers/net/vrf.c            |  654 +++++++++++++++++++++++++++++++=
+++++++++++

I'm not really in favor of the name 'vrf'. This term is very controvers=
ial and
having a consensus of what is/contains a 'vrf' is quite impossible.
There was already a lot of discussions about this topic on quagga ml th=
at show
that everybody has a different opinion about this term ;-)

I know you call this 'MRF' internally, why not using this name instead?


Regards,
Nicolas
