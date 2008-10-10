From: Scott Feldman <sfeldma@nuovasystems.com>
Subject: Re: drivers/net/enic/vnic_cq.c
Date: Fri, 10 Oct 2008 11:29:23 -0700
Message-ID: <C514ED13.C7D0%sfeldma@nuovasystems.com>
References: <adaabdcjrz8.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <akpm@linux-foundation.org>, <mingo@elte.hu>,
	<netdev@vger.kernel.org>
To: Roland Dreier <rdreier@cisco.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:24067 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759345AbYJJS30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 14:29:26 -0400
In-Reply-To: <adaabdcjrz8.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/08 10:10 AM, "Roland Dreier" <rdreier@cisco.com> wrote:

> cc'ing Scott so we can make sure that this actually is atomic enough to
> work with the enic hardware... (Scott, the context is that enic won't
> build on any architecture that doesn't define writeq and readq, such as
> 32-bit x86; however the definitions below make it possible that multiple
> 32-bit writes will be interleaved, eg if an interrupt occurs between the
> first writel and the second writel)

Yes, enic hw provides atomic read/write for 64-bit regs even if register is
accessed with 32-bit read/writes.

-scott

