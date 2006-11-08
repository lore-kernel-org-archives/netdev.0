From: Olaf Kirch <okir@suse.de>
Subject: Re: 2.6.19-rc1: Volanomark slowdown
Date: Wed, 8 Nov 2006 17:29:55 +0100
Message-ID: <20061108162955.GA4364@suse.de>
References: <1162924354.10806.172.camel@localhost.localdomain> <1163001318.3138.346.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tim.c.chen@linux.intel.com, linux-kernel@vger.kernel.org,
	davem@sunset.davemloft.net, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42730 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1161138AbWKHQaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 11:30:10 -0500
To: Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <1163001318.3138.346.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 08, 2006 at 04:55:18PM +0100, Arjan van de Ven wrote:
> I wonder if it's an option to use low priority QoS fields for these acks
> (heck I don't even know if ACKs have such fields in their packet) so
> that they can get dropped if there are more packets then there is
> bandwidth ....

Is it proven that the number of ACKs actually cause bandwidth problems?
I found Volanomark to exercise the scheduler more than anything else,
so maybe the slowdown, while triggered by an increased number of ACKs,
is caused by something else entirely.

Olaf
-- 
Walks like a duck. Quacks like a duck. Must be a chicken.
