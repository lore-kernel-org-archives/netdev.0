From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: what is the expeted performance from a dual port 10G card ?
Date: Sat, 29 Nov 2008 17:34:43 +0000
Message-ID: <20081129173442.GI32518@solarflare.com>
References: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com> <20081128135419.GH32518@solarflare.com> <5d96567b0811290010r641388b7w179bc4af26bbf103@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Raz <raziebe@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:58535 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751393AbYK2Ret (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 12:34:49 -0500
Content-Disposition: inline
In-Reply-To: <5d96567b0811290010r641388b7w179bc4af26bbf103@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Raz wrote:
> PCI Encoding overhead is 8 bits /10 bits . so 16Gbps supposed to be
> the practical limit.

The 8b10 encoding is already accounted for in the 2.5 Gbps figure;
the raw bit rate is 3.125 Gbps.

I'm thinking about the transaction layer overhead.  Since PCI Express
has few side-band signals there is a protocol a little like TCP running
over the link, which adds a header to each request or response packet
(TLP).  The maximum TLP size is usually quite small so the header
accounts for a fair proportion of the link bandwidth.

> I still lack 3 Gbps in the Intel case. where are they ?

That's for Intel to answer.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
