From: Gene Heskett <gene.heskett@gmail.com>
Subject: Re: [git patches] net driver updates
Date: Fri, 18 May 2007 18:19:50 -0400
Message-ID: <200705181819.50614.gene.heskett@verizon.net>
References: <20070508063337.GA12474@havoc.gtf.org> <200705182346.21835.m.kozlowski@tuxland.pl> <20070518145425.369cb9ff.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mariusz Koz__owski <m.kozlowski@tuxland.pl>,
	Jeff Garzik <jeff@garzik.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:24807 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755422AbXERWT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 18:19:57 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1047902wxd
        for <netdev@vger.kernel.org>; Fri, 18 May 2007 15:19:53 -0700 (PDT)
In-Reply-To: <20070518145425.369cb9ff.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 18 May 2007, Andrew Morton wrote:
>On Fri, 18 May 2007 23:46:21 +0200
>
>Mariusz Koz__owski <m.kozlowski@tuxland.pl> wrote:
>> Hello,
>>
>> > diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
>> > index 7053026..111f23d 100644
>> > --- a/drivers/net/smc91x.h
>> > +++ b/drivers/net/smc91x.h
>> > @@ -279,6 +279,40 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
>>
>> ...
>>
>> > +#define SMC_outb(v, a, r) __ __
>> > __outw(((inw((a)+((r)&~1))*(0xff<<8*(r%2)))) | ((v)<<(8*(r&2)))), (a) +
>> > ((r)&~1))
>>
>> This one has unbalanced parenthesis.
>
>I dunno how you can tell - I can't count that high.
>
Try removing the one in front of the comma, it makes the count -1.  And I 
wrote, probably a good 20 years ago, a gizmo I called cntx that found that 
stuff for you.  I occasionally use it to run over a section of the kernel 
tree, but it rarely finds anything to fuss about.  And I really do need to 
make it handle shell expansions so you don't have write a quick script to 
have it scan everything in a directory.  However I suspect that most of you 
already have such a tool in your bag of tricks.

>Can this be programmed in C, rather than in cpp?
>-
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/



-- 
Cheers, Gene
"There are four boxes to be used in defense of liberty:
 soap, ballot, jury, and ammo. Please use in that order."
-Ed Howdershelt (Author)
I'm definitely not in Omaha!
