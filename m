From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: what is the expeted performance from a dual port 10G card ?
Date: Fri, 28 Nov 2008 13:54:20 +0000
Message-ID: <20081128135419.GH32518@solarflare.com>
References: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Raz <raziebe@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:49590 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753384AbYK1Ny2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 08:54:28 -0500
Content-Disposition: inline
In-Reply-To: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Raz wrote:
> Hello
> I have been testing 10G ethernet cards , intel ixgbe, chelsio, tehuti
> and melanox . All are dual port cards.
> I have used pktgen to test it. A single cpu is mapped over a single
> interface (no neeed for MQ , which is quite bad anyway).
> Results:
> Intel gives: 13Gbps , 6.5 from each port.
> The rest give ~10 Gbps .
> Cards were tested on PCI-E x8 slot, on a supermicro x7DBI and
> supermicro 1025W-UR.
> 
> Am i to expect ~20Gbps from each card ?

PCI Express provides 2.5 Gbps per lane (can be 5 Gbps in PCIe 2.0 but
that's quite new).  So an x8 slot is limited to 20 Gbps including all
the PCIe protocol overhead, which can be substantial.  You will not
get 20 Gbps out of dual-port cards without doubling the width or lane
speed.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
