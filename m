From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 18:31:55 +0400
Message-ID: <46D8265B.6000405@bigtelecom.ru>
References: <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local> <46D7E050.1030303@bigtelecom.ru> <20070831101733.GA3108@ff.dom.local> <46D7F1FF.1000101@bigtelecom.ru> <20070831125917.GC3108@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:50734 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276AbXHaOb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 10:31:57 -0400
In-Reply-To: <20070831125917.GC3108@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok =) I hope in next week you found bug place and fix it!

PS. if you ask where i can read "kernel panic dump logic" literature and 
try find bugline in code.
I read dump and see that bug in function "rb_insert_color" + some shift 
(in asm?) that called from htb_dequeue? But in htb_dequeue not have 
calling rb_insert_color =( Or some nodes in trace was skipped?

Its for change up my education ;)
> I'll not be able to assist you until monday (but I'll try to look
> into the code and maybe to prepare some new patch - but it needs
> a lot of checking to not add too much of this locking as well).
>
> I think you can stay with a kernel whichever you like - I'm not sure
> any config changes or even more debugging can change much, but maybe
> I'm wrong. It looks to me like some locking is missing or interrupted.
> If you are working weekends and find something new, don't wait: maybe
> somebody else here could be interested too.
>  
> Cheers,
> Jarek P. 
>
>   

