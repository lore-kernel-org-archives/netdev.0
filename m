From: Andi Kleen <ak@suse.de>
Subject: Re: divide error: 0000 in fib6_rule_match [Re: 2.6.18-rc4-mm3]
Date: Mon, 28 Aug 2006 23:22:48 +0200
Message-ID: <200608282322.48307.ak@suse.de>
References: <20060826160922.3324a707.akpm@osdl.org> <20060828200716.GA4244@inferi.kami.home> <20060828132820.ae12ce4f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mattia Dongili <malattia@linux.it>, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39847 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751517AbWH1VXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 17:23:21 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060828132820.ae12ce4f.akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I cannot work out how the heck you got a divide instruction in
> fib6_rule_match().

This might be another symptom of the broken smp-alternatives patch.
It tended to randomly corrupt some instructions by inserting different
bytes which then crash in interesting ways.

I already sent a fix for that, but it's not in yet.

-Andi
