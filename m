From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 (was Re: 2.6.18-mm2)
Date: Sun, 8 Oct 2006 09:20:01 -0700
Message-ID: <20061008092001.0c83a359@localhost.localdomain>
References: <20060928155053.7d8567ae.akpm@osdl.org>
	<451C5599.80402@garzik.org>
	<20060928161956.5262e5d3@freekitty>
	<1159930628.16765.9.camel@mhcln03>
	<20061003202643.0e0ceab2@localhost.localdomain>
	<1160250529.4575.7.camel@mhcln03>
	<1160314905.4575.21.camel@mhcln03>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Andrew Morton <akpm@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18657 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751256AbWJHQW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2006 12:22:57 -0400
To: Matthias Hentges <oe@hentges.net>
In-Reply-To: <1160314905.4575.21.camel@mhcln03>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 08 Oct 2006 15:41:45 +0200
Matthias Hentges <oe@hentges.net> wrote:

> Hi Stephen,
> 
> I believe I have identified the problem. The freeze only happens when
> your debug patch to work around sky2 PCIe error messages is applied.
> Without your patch (attached) I get _tons_ of error messages and the NIC
> dies every few seconds / minutes (reproduceable!), but the system
> recovers just fine from a NIC crash.
> 
> I have verified this behavior (works fine w/o debug patch, freezes with
> patch applied) with:
> - 2.6.19-rc1-git4 
> - 2.6.18-git something 
> - 2.6.18-mm3
>   

Does 2.6.18 work?

What is the PCI config of the device (lspci -vvvx)?

What is the chip version (dmesg | grep sky2)?

