From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Tue, 01 May 2012 07:57:29 +1000
Message-ID: <1335823049.20866.48.camel@pasglop>
References: <1335760199.20866.33.camel@pasglop>
	 <4F9E188E.80503@googlemail.com> <1335763568.20866.37.camel@pasglop>
	 <20120430.134140.1738751315208907289.davem@davemloft.net>
	 <1335822926.20866.47.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kaffeemonster@googlemail.com, eric.dumazet@gmail.com,
	matt@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58281 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756383Ab2D3V5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 17:57:42 -0400
In-Reply-To: <1335822926.20866.47.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-01 at 07:55 +1000, Benjamin Herrenschmidt wrote:
> On Mon, 2012-04-30 at 13:41 -0400, David Miller wrote:
> > From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > Date: Mon, 30 Apr 2012 15:26:08 +1000
> > 
> > > David, what's the right way to fix that ?
> > 
> > There is no doubt that sock_fprog is the correct datastructure to use.
> 
> Ok, so the right fix is to email anybody who posted code using struct
> bpf_program to fix their code ? :-)

Actually, the right fix is for anybody using pcap-bpf.h to not
use SO_ATTACH_FILTER directly but to use pcap_setfilter() which
handles the compatibility.

I'll start spamming web sites who tell people to do the wrong thing.

Cheers,
Ben.
