From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFT 3/4] Use mod_timer_noact to remove nf_conntrack_lock
Date: Wed, 18 Feb 2009 12:08:29 +0100
Message-ID: <499BEC2D.5040104@trash.net>
References: <20090218110522.GA5408@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	tglx@linutronix.de, netfilter-devel@vger.kernel.org,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49428 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbZBRLIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 06:08:34 -0500
In-Reply-To: <20090218110522.GA5408@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On 18-02-2009 06:19, Stephen Hemminger wrote:
>> Now that we are using mod_timer_noact() for timer updates there's no need to
> 
> Hmm... so where exactly we are using this mod_timer_noact() now?

Hehe, good point, the conversion to actually use it seems to
be missing :)
