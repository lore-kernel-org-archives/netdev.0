From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [v2] Re: [RFC] l2tp/ipv6: support for L2TPv2 over UDP over IPv6
Date: Tue, 10 Apr 2012 14:49:16 -0400
Message-ID: <20120410184916.GE24092@kvack.org>
References: <20120214223112.GB6806@kvack.org> <1329282410.2555.31.camel@edumazet-laptop> <4F3B6C26.4090701@katalix.com> <4F632FB6.9010206@katalix.com> <20120319032807.GD11293@kvack.org> <4F840FCB.9050504@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:45711 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754043Ab2DJStR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 14:49:17 -0400
Content-Disposition: inline
In-Reply-To: <4F840FCB.9050504@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 11:47:39AM +0100, James Chapman wrote:
> We've tested this in several L2TP environments - looks good. Will you be
> submitting a version soon?

Yes.  I'll try to get that out tonight now that net-next is open again.

Also, I found a bug in OpenL2TPd (1.8 I think): certain types of AVPs are 
not accepted if they are hidden, despite the fact that RFC 2661 permits 
hiding these AVPs.  The AVPs in question are: Assigned Tunnel ID, Challege, 
Challenge Response and Assigned Session ID.

		-ben
-- 
"Thought is the essence of where you are now."
