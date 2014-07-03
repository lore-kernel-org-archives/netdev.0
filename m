From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Wed, 02 Jul 2014 22:16:05 -0700
Message-ID: <1404364565.14741.26.camel@joe-AO725>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>
	 <20140702.182807.1245632778216212860.davem@davemloft.net>
	 <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>
	 <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
	 <1404356734.14741.18.camel@joe-AO725>
	 <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0101.hostedemail.com ([216.40.44.101]:39778 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751343AbaGCFQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 01:16:09 -0400
In-Reply-To: <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-03 at 05:51 +0100, Maciej W. Rozycki wrote:
> > The kernel vsprintf implementation doesn't prefix
> > pointers with 0x, so you can use 0x%p if you really
> > want that with a leading prefix, but you don't have
> > to use it.
> 
>  It does, when the `#' format modifier is used (go try yourself!).

I know it does, but it's incidental.

I phrased it badly though.
There's no code that uses it.

$ git grep "%#p" | wc -l
0

And I know that code pretty well thanks.

> I think using 0x%p 
> would be ugly; here it wouldn't really matter, but ordinarily allowing a 
> format to produce `0x (null)' would be rather lame, so I don't want to 
> spread examples someone might foolishly copy.

$ git grep "0x%p" | wc -l
1747

<shrug>  What's one more...

cheers, Joe
