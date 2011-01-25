From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: remove tests on 64bit platforms
Date: Tue, 25 Jan 2011 14:28:49 +1000
Message-ID: <1295929729.2896.26.camel@localhost>
References: <1295929298-13163-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42153 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650Ab1AYE2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 23:28:53 -0500
In-Reply-To: <1295929298-13163-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-25 at 12:21 +0800, Changli Gao wrote:
> On 64bit platforms, >31 bit shifting of a unsigned long variable is
> valid, so we can remove the related boundary tests, which may slow
> down the CPU if branch prediction fails.
[...]

It seems like it would be better to define generic shift functions that
correctly handle the case of a shift count >= word size.  There are many
places these would be useful.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

