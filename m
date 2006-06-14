From: Patrick McHardy <kaber@trash.net>
Subject: Re: http://bugzilla.kernel.org/show_bug.cgi?id=6197
Date: Wed, 14 Jun 2006 16:04:13 +0200
Message-ID: <4490175D.1020106@trash.net>
References: <20060611055132.2930b95f.akpm@osdl.org> <448EE065.9060207@trash.net> <448F304A.2020808@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:5358 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S964950AbWFNOEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 10:04:14 -0400
To: Michael Tokarev <mjt@tls.msk.ru>
In-Reply-To: <448F304A.2020808@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Tokarev wrote:
> Patrick McHardy wrote:
> []
> 
>>He patched his kernel with the IMQ device, which is known to cause all
>>kinds of weird problems.
> 
> 
> Wich problems?  Known to whom?

Known to me (who wrote the original implementation of the current IMQ
device) and numerous people who were hit by them. IIRC it does some
invalid skb refcounting hacks which result in crashes in certain
scenarios - but I don't remeber the exact details.

> I was considering using imq for our needs (not done yet), and from the
> FAQ at http://www.linuximq.net/faq.html (item #3, "Is it stable?") it
> seems there's no problems except of gre tunnels and locally generated
> traffic...
> 
> Googling for "imq linux problem" shows usual pile of various user
> support questions (how to configure.. what did I do wrong.. etc),
> but nothing relevant.

The lartc list had lots of reports of crashes. I guess "imq crash" or
"imq oops" will give better results.

> So... I'm curious whenever the claim on linuximq.net site about the
> stability is true, or there in fact are some real issue...

>From what I know these problems haven't been fixed. Current kernels
include Jamal's tc actions and the ifb-Device, which obsolete IMQ
anyway.

