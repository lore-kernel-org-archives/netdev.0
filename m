From: jamal <hadi@cyberus.ca>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Mon, 05 Nov 2007 08:47:06 -0500
Message-ID: <1194270426.4438.100.camel@localhost>
References: <1193939701.2987.82.camel@localhost.localdomain>
	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>
	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>
	 <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>
	 <20071105091231.GA1933@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:9641 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755482AbXKENtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 08:49:02 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1978041wah
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2007 05:49:01 -0800 (PST)
In-Reply-To: <20071105091231.GA1933@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-11 at 10:12 +0100, Jarek Poplawski wrote:

> BTW: when looking around this I think, maybe, in u32_change():
> 
> 1) if (--divisor > 0x100) should be probably ">=", 

Does it really matter? Divisor can be max of 0xff.

> but is it really needed to check this 2 times (including tc)?

I dont mind letting users shoot themselves in the foot by sending crap.
If it can be avoided with simplicity, then better.

> 2) this while() loop for n->fshift could be replaced with ffs()?

I think so. Can you please send a patch (after some testing of course
maybe using Radu's test data)?

cheers,
jamal

