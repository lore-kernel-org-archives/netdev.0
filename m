From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Kernel header changes break glibc build
Date: Wed, 06 Dec 2006 14:01:55 +0000
Message-ID: <1165413715.5253.226.camel@pmac.infradead.org>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk>
	 <1165148731.12649.51.camel@pmac.infradead.org>
	 <20061204091341.GM8693@postel.suug.ch>
	 <1165410114.5253.218.camel@pmac.infradead.org>
	 <20061206134308.GL9556@sunsite.mff.cuni.cz>
	 <1165413068.5253.223.camel@pmac.infradead.org>
	 <20061206135730.GM9556@sunsite.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ulrich Drepper <drepper@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	"Joseph S. Myers" <joseph@codesourcery.com>,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:52531 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760626AbWLFOCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 09:02:03 -0500
To: Jakub Jelinek <jakub@redhat.com>
In-Reply-To: <20061206135730.GM9556@sunsite.mff.cuni.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-06 at 14:57 +0100, Jakub Jelinek wrote:
> Yes, but as I said, I'd need to add configure checks for that, using
> #include <linux/if_addr.h>
> alone breaks build with older headers.

I was thinking that the #ifndef IFA_MAX you already have ought to be
sufficient for that. Or even checking KERNEL_VERSION.

-- 
dwmw2

