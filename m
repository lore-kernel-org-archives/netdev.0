From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Tue, 08 Jan 2008 01:23:11 +0100
Message-ID: <p73sl19qi6o.fsf@bingen.suse.de>
References: <1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi>
	<E1JBJOR-0000jO-00@gondolin.me.apana.org.au>
	<20080105.231658.168081302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, acme@redhat.com, paul.moore@hp.com,
	latten@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:36955 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753553AbYAHAXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 19:23:15 -0500
In-Reply-To: <20080105.231658.168081302.davem@davemloft.net> (David Miller's message of "Sat\, 05 Jan 2008 23\:16\:58 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> Similarly I question just about any inline usage at all in *.c files

Don't forget the .h files. Especially a lot of stuff in tcp.h should
be probably in some .c file and not be inline.

-Andi
