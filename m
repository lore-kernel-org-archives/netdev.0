From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] div64_64 support
Date: Tue, 6 Mar 2007 20:48:41 +0100
Message-ID: <20070306194841.GA5424@one.firstfloor.org>
References: <20070223170527.4ca695b2@freekitty> <20070305155714.3abe1b5e@freekitty> <20070306133404.GA864@one.firstfloor.org> <200703061519.20346.dada1@cosmosbay.com> <20070306144529.GA2004@one.firstfloor.org> <84C47260-4B57-4568-8197-58F438A6F737@e18.physik.tu-muenchen.de> <20070306102941.32471d57@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Kuhn <rkuhn@e18.physik.tu-muenchen.de>,
	Andi Kleen <andi@firstfloor.org>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:37814 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933307AbXCFTsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 14:48:43 -0500
Content-Disposition: inline
In-Reply-To: <20070306102941.32471d57@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 10:29:41AM -0800, Stephen Hemminger wrote:
> Don't count the existing Newton-Raphson out. It turns out that to get enough
> precision for 32 bits, only 4 iterations are needed. By unrolling those, it
> gets much better timing.

But did you fix the >2^43 bug too?

SGI has already shipped 10TB Altixen, so it's not entirely theoretical.

-Andi

