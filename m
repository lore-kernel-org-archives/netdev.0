From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] Fix netfilter xt_time's time_mt()'s use of do_div()
Date: Tue, 15 Jul 2008 14:08:31 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0807151400160.13215@fbirervta.pbzchgretzou.qr>
References: <20080711140206.982.19421.stgit@warthog.procyon.org.uk> <487C8D60.9040405@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Howells <dhowells@redhat.com>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:52942 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947AbYGOMId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 08:08:33 -0400
In-Reply-To: <487C8D60.9040405@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2008-07-15 13:43, Patrick McHardy wrote:

> David Howells wrote:
>> Fix netfilter xt_time's time_mt()'s use of do_div() on an s64 by using
>> div_s64() instead.
>> 
>> This was introduced by patch ee4411a1b1e0b679c99686629b5eab5a072ce49f.
>
> Alternatively we could use an u64 for the time. Jan, any preferences?

ktime_t and ktime_to_ns operate on signed quantities. I do not think we 
should be interpreting it as unsigned.
