From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Fix netfilter xt_time's time_mt()'s use of do_div()
Date: Tue, 15 Jul 2008 13:43:28 +0200
Message-ID: <487C8D60.9040405@trash.net>
References: <20080711140206.982.19421.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jengelh@computergmbh.de, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55241 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696AbYGOLnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 07:43:31 -0400
In-Reply-To: <20080711140206.982.19421.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Howells wrote:
> Fix netfilter xt_time's time_mt()'s use of do_div() on an s64 by using
> div_s64() instead.
> 
> This was introduced by patch ee4411a1b1e0b679c99686629b5eab5a072ce49f.

Alternatively we could use an u64 for the time. Jan, any preferences?

