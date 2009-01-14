From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PULL -tip] fixed few make headers_check warnings
Date: Wed, 14 Jan 2009 16:58:50 +0100
Message-ID: <496E0BBA.6040403@hartkopp.net>
References: <1231836016.3212.41.camel@jaswinder.satnam> <20090113124921.GA30400@elte.hu> <20090114154057.GC32082@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Jaswinder Singh Rajput <jaswinder@infradead.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	x86 maintainers <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:9333 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbZANP6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 10:58:53 -0500
In-Reply-To: <20090114154057.GC32082@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sam Ravnborg wrote:
> As they are one-liners for the most part I am fine with you handling
> them in a separate branch.
>   

Hi Sam,

i would split them up:

One big single patch only for this

-#include <asm/types.h>
+#include <linux/types.h>

and this

+#include <linux/types.h>

which is trivial.

And all the other stuff should additionally go through the maintainers hands (at least).


Oliver

