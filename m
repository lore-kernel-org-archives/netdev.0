From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] div64_64 support
Date: Tue, 6 Mar 2007 12:04:33 -0800
Message-ID: <20070306120433.3863e6c9@freekitty>
References: <20070223170527.4ca695b2@freekitty>
	<20070305155714.3abe1b5e@freekitty>
	<20070306133404.GA864@one.firstfloor.org>
	<200703061519.20346.dada1@cosmosbay.com>
	<20070306144529.GA2004@one.firstfloor.org>
	<84C47260-4B57-4568-8197-58F438A6F737@e18.physik.tu-muenchen.de>
	<20070306102941.32471d57@freekitty>
	<20070306194841.GA5424@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roland Kuhn <rkuhn@e18.physik.tu-muenchen.de>,
	Andi Kleen <andi@firstfloor.org>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:55345 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751325AbXCFUIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 15:08:23 -0500
In-Reply-To: <20070306194841.GA5424@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Mar 2007 20:48:41 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> On Tue, Mar 06, 2007 at 10:29:41AM -0800, Stephen Hemminger wrote:
> > Don't count the existing Newton-Raphson out. It turns out that to get enough
> > precision for 32 bits, only 4 iterations are needed. By unrolling those, it
> > gets much better timing.
> 
> But did you fix the >2^43 bug too?

It was caused by not doing x^2 in 64 bit.

> 
> SGI has already shipped 10TB Altixen, so it's not entirely theoretical.
> 
> -Andi
> 


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
