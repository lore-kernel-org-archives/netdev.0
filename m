From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: fscked clock sources revisited
Date: Mon, 30 Jul 2007 19:03:58 -0700
Message-ID: <1185847438.2683.4.camel@laptopd505.fenrus.org>
References: <1185844239.5162.17.camel@localhost>
	 <20070730.183750.77058266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:38111 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758487AbXGaCGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 22:06:46 -0400
In-Reply-To: <20070730.183750.77058266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-07-30 at 18:37 -0700, David Miller wrote:

> There really isn't much that can be done by any of this.  These issues
> exist because of hardware limitations, nobody bothered to build
> x86/x86_64 systems with a system wide TICK register that is both
> impervious to cpu frequence scaling and also cheap to access.

actually the tsc is clock speed invariant on pretty much all cpus these
days. The problem is that it stops in deeper idle states... (and that it
may be out of sync on an multi-socket system) not that it keeps changing
frequency ;(

(so it still sucks, just differently)

