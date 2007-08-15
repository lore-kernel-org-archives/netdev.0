From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Wed, 15 Aug 2007 23:15:51 +0200
Message-ID: <7131d547746a998fcec74d1c091f9f6a@kernel.crashing.org>
References: <20070809134150.GA14890@shell.boston.redhat.com> <2708.1186737826@redhat.com> <7680.1186822071@redhat.com> <46BFFDBD.6080804@redhat.com> <46C140DD.3060509@yahoo.com.au> <2cbda24e96a49c3ab7cf7039c515f9fc@kernel.crashing.org> <20070815191829.GJ9645@linux.vnet.ibm.com> <369924c4b3132a4b06258b7ac81b1006@kernel.crashing.org> <20070815195915.GL9645@linux.vnet.ibm.com> <d2cd1065faf8a13040e8a2405c363aa1@kernel.crashing.org> <20070815203836.GO9645@linux.vnet.ibm.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com, zlynx@acm.org,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	davem@davemloft.net, wensong@linux-vs.org, wjiang@resilience.com,
	David Howells <dhowells@redhat.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53881 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758406AbXHOVQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 17:16:47 -0400
In-Reply-To: <20070815203836.GO9645@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Please check the definition of "cache coherence".

Which of the twelve thousand such definitions?  :-)

> Summary: the CPU is indeed within its rights to execute loads and 
> stores
> to a single variable out of order, -but- only if it gets the same 
> result
> that it would have obtained by executing them in order.  Which means 
> that
> any reordering of accesses by a single CPU to a single variable will be
> invisible to the software.

I'm still not sure if that applies to all architectures.
Doesn't matter anyway, let's kill this thread :-)


Segher

