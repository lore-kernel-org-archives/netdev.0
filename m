From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: do not set "u" bit for temporary addresses
Date: Thu, 13 Feb 2014 01:11:49 +0100
Message-ID: <20140213001149.GI11150@order.stressinduktion.org>
References: <1392203286-17833-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50750 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbaBMAMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 19:12:10 -0500
Content-Disposition: inline
In-Reply-To: <1392203286-17833-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 12:08:06PM +0100, Florent Fourcot wrote:
> The bit 6 of interface identifier was before the "universal/local bit",
> indicating local significance only. This rule is now obsoleted by the
> RFC 7136, removing all significance of bits in interface identifier.
> 
> The new rule is "In all cases, the bits in an IID have no generic
> semantics; in other words, they have opaque values.", so we can remove
> the setting of bit 6, it will improve the entropy of random addresses.
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Hmm, the RFC only talks about new methods of IID generation. Not sure
if old software depends on that. I actually know about one commercial
available ip management system which does make use of those bits to
classify ipv6 addresses for displaying purposes (that's how I actually
learned about those bits ;) ).

Greetings,

  Hannes
