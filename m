From: Matt Mackall <mpm@selenic.com>
Subject: Re: [BUG] bad address in twothirdsMD4Transform
Date: Mon, 11 Feb 2008 13:42:40 -0600
Message-ID: <1202758960.12383.2.camel@cinder.waste.org>
References: <47B0A220.8040400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:48318 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755594AbYBKTnj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 14:43:39 -0500
In-Reply-To: <47B0A220.8040400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-02-11 at 20:29 +0100, Jiri Slaby wrote:
> Hi,
> 
> I get this with 32 bit Firefox 3b2 and java 1.6.0_03 on 64 bit:
> 
> BUG: unable to handle kernel paging request at ffff8102366213f8
> IP: [<ffffffff803558f4>] twothirdsMD4Transform+0xc4/0x3b0

You should mention what kernel you're using. This bug is only in -mm
(you didn't cc: Andrew), and it's fixed here:

http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24/2.6.24-mm1/hot-fixes/random-clean-up-checkpatch-complaints-fix.patch

-- 
Mathematics is the supreme nostalgia of our time.

