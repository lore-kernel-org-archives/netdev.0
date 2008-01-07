From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [patch 5/9][NETNS][IPV6] make bindv6only sysctl per namespace
Date: Mon, 7 Jan 2008 17:49:01 +0100
Message-ID: <20080107174901.f365a6f2.dada1@cosmosbay.com>
References: <20080104111226.776105484@localhost.localdomain>
	<20080104111431.444295890@localhost.localdomain>
	<47825402.8030504@bull.net>
	<47825513.50100@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Benjamin Thery <benjamin.thery@bull.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:57780 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755752AbYAGQtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 11:49:05 -0500
In-Reply-To: <47825513.50100@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Jan 2008 17:36:35 +0100
Daniel Lezcano <dlezcano@fr.ibm.com> wrote:

> Benjamin Thery wrote:
> > Daniel,
> > 
> > The kernel fails to build with this patch applied when CONFIG_SYSCTL=n
> > See comment below.
> > 
> > Daniel Lezcano wrote:
> >> This patch moves the bindv6only sysctl to the network namespace
> >> structure. Until the ipv6 protocol is not per namespace, the sysctl
> >> variable is always from the initial network namespace.
> 
> Argh !
> 
> Thanks Benjamin to catch this.
> 
> I think I have to apologize to Eric, I thought I tested with this option 
> off but it wasn't and Eric was right. I will wait a little for feedbacks 
> and send a V3.

No problem Daniel :)
