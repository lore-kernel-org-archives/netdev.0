From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC] Per route TCP options
Date: Wed, 21 Oct 2009 10:21:09 +0200
Message-ID: <20091021082109.GE8704@Chamillionaire.breakpoint.cc>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
 <4ADDE4C4.5080501@hp.com>
 <4ADEC076.2030105@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	ori@comsleep.com
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:54310 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752028AbZJUIVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 04:21:08 -0400
Content-Disposition: inline
In-Reply-To: <4ADEC076.2030105@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef <gilad@codefidence.com> wrote:
> The point is that even then you are more then likely to wish to turn
> off these options to specific destination and routes (that go over
> said exotic link) and keep using them over others - e.g. timestamp
> OK for local LAN, but for default route that goes over exotic TCP/IP
> over carrier penguins turn it off.

If you need a bandaid solution, its is possible to replace tcp
options with NOOPs using netfilters TCPOPTSTRIP target.

There is also an ECN target to work around ECN blackholes.
