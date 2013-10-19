From: Valentijn Sessink <valentyn@blub.net>
Subject: Re: IPv6 path discovery oddities - flushing the routing cache resolves
Date: Sat, 19 Oct 2013 16:24:59 +0200
Message-ID: <5262963B.8040001@blub.net>
References: <525E6B03.1040409@blub.net> <20131016154841.GC18135@order.stressinduktion.org> <525FC1C4.3070605@blub.net> <20131018030440.GI18135@order.stressinduktion.org> <5260D8DE.30303@blub.net> <20131019084225.GA31333@order.stressinduktion.org> <20131019101246.GA27576@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([178.63.187.165]:53734 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217Ab3JSOZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 10:25:08 -0400
In-Reply-To: <20131019101246.GA27576@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

op 19-10-13 12:12, Steinar H. Gunderson schreef:
> Thanks so much for looking into this! It's great that to hear that it's not
> just me being weird =)

I'm not sure the patch addresses weirdness ;-P

On the more serious side: I have this problem with a 3.8.0 kernel 
(Ubuntu 12.04 with updated kernel). I saw that you (Steinar) experience 
this with 3.10 and 3.11, iirc. I'm a little bit worried by the fact that 
this has not been seen for at least six months - and now suddenly pops up.

Does anyone have an idea when this race condition was introduced?

(It could be, that certain patches have been included in Ubuntu 
3.8.0-something but not in an official 3.8).

Best regards,

Valentijn
p.s. I won't be able to test any patches until tuesday - sorry.
