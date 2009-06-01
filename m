From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Mon, 1 Jun 2009 18:19:17 +0200
Message-ID: <20090601161917.GA29745@Chamillionaire.breakpoint.cc>
References: <4A23F027.3060907@dev.6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:39403 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751818AbZFAQTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 12:19:16 -0400
Content-Disposition: inline
In-Reply-To: <4A23F027.3060907@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@dev.6wind.com> wrote:
> when network stack receives a packet, it didn't check value of ttl/hop 
> limit
> field. RFC indicates that a router must drop the packet if this field is 0.

Whats wrong with the checks in ip(6)_forward?
