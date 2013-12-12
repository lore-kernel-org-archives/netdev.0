From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity
 protection
Date: Thu, 12 Dec 2013 07:33:41 -0800
Message-ID: <1386862421.19078.67.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52A75EF8.3010308@in.tum.de>
	  <20131211.150137.368953964178408437.davem@davemloft.net>
	  <52A8C8B4.4060109@in.tum.de>
	  <20131211122637.75b09074@nehalam.linuxnetplumber.net>
	  <87bo0nulkt.fsf@tassilo.jf.intel.com> <52A8ECF5.3070604@in.tum.de>
	  <20131212012317.GL21717@two.firstfloor.org>
	  <52A98DBF.4090702@appelbaum.net> <52A9A17F.6050505@in.tum.de>
	 <1386858864.19078.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52A9D125.9080701@in.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jacob Appelbaum <jacob@appelbaum.net>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, knock@gnunet.org
To: Christian Grothoff <grothoff@in.tum.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:36934 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702Ab3LLPdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 10:33:44 -0500
In-Reply-To: <52A9D125.9080701@in.tum.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-12 at 16:07 +0100, Christian Grothoff wrote:

> I'm already having fun with IETF and pTLDs right now, one war at a time
> ;-).  I also figured it might be easier to have a reasonable working
> reference implementation first and then standardize.  After all, with my
> recent draft some people at IETF suggested I should get 1,000,000+ users
> first and then ask again.

Honestly, breaking the detection of old packets (PAWS) is not going to
fly. Its not even mentioned in your doc.

If a client uses the same ISN for two consecutive connexions to a
server, how the server can decide the 2nd SYN is not a duplicate ?

You really need more than 3 pages to fully investigate all the pros/cons
of this idea.
