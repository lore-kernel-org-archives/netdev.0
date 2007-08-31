From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 14:48:31 +0400
Message-ID: <46D7F1FF.1000101@bigtelecom.ru>
References: <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local> <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local> <46D7E050.1030303@bigtelecom.ru> <20070831101733.GA3108@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:36743 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755058AbXHaKse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 06:48:34 -0400
In-Reply-To: <20070831101733.GA3108@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> But sometime a new kernel can break binary compatibility with previous
> one (e.g. after data structures change) and e.g. iptables or iproute
> tools stop working or work in an unpredictable way. There were a few
> such changes before 2.6.20 - I don't track current changes too much.
> And I'm sure your system uses much more than iptables or TC, even
> without your knowledge.
>   
I can rollback =)  Backup system get all functions. I can risk for one 
system of two for get and fix all bugs.
Dynamic routing work fine and automatic switch between systems = 1-4 
seconds.

>> I send to you all info that catch NETCONSOLE. i don't cut any info...
>>     
>
> So, it seems something was broken. But, I meant, there can be sometimes
> interesting things a few lines before or after the infos too.
>   
I can only see that say netconsole. If i look to monitor i look last 
lines. last line is "====...". Scrolling not work
netconsole run as module and start after system do full load. Then 
netconsole is up - i run generator of tc scripts.
> BTW, -git versions are usually more risky than -rc. And, maybe, let
> this 2.6.18 better stay away from this testing...
>   
I look changes between 2.6.23-rc4 and 2.6.23-rc4-git2 and think that 
paches look good and no do any critical things =)

Now i do many script runs to simulate bug. if i get it on 2.6.23-rc4 - i 
post it here. 2.6.23-rc4 not have htb_timer function.

Badalian Vyacheslav
