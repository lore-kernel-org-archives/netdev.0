From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Machine Check Exception Re: NetDev! Please help!
Date: Tue, 23 Sep 2008 16:16:51 +0400
Message-ID: <48D8DE33.6000605@bigtelecom.ru>
References: <48D67239.9040006@gmail.com> <48D7385D.40107@bigtelecom.ru> <20080922065339.GA4399@ff.dom.local> <48D76813.9000603@bigtelecom.ru> <20080922112452.GB5314@ff.dom.local> <48D79709.80400@bigtelecom.ru> <20080922172349.GA2545@ami.dom.local> <48D89E0C.9040407@bigtelecom.ru> <20080923092504.GB4692@ff.dom.local> <48D8C695.2020302@bigtelecom.ru> <20080923115708.GC4692@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:38159 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbYIWMQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 08:16:55 -0400
In-Reply-To: <20080923115708.GC4692@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Actually, I don't use these things too much, but I guess, you'll need
> this more. Main issues were tested and fixed, but there could be always
> some details not used, not noticed or not reported until you decide to
> use this.
>   

Yep. I will begin test it in this week if i can get time for it...

> Yes, I'm not sure I understand question, but I think you shouldn't
> expect too much, at least in 2.6.27. There is many work now in drivers
> around this multiqueing (and RX hashing), which should be available in
> next kernels, but I'm not tracking this too much... Anyway, with the
> basic support (which really isn't common for drivers in 2.6.27 yet),
> this separation is done only for TX just before enqueuing.
>
>   
I simple hope that after divide to bands/queues and go back to network
all packets save "First in and First Out" logic that needed in services
like video streaming...

> sch_multiq doesn't use any params for hashing now - it uses mapping
> in packets to separate them to different bands/queues. So, by default
> it'll respect common hashing. You can change this using any filter with
> act_skbedit (Documentation/networking/multiqueue.txt).
>
>   
Ok! I will read all related information and rewrite all tc generate
scripts to test it!

> Don't worry, English should understand...
>
>   
Great what world have people that read messages like this and try
understand it... thanks!

> OOPS!!! This 2.6.27-rc is so ...old I forgot the sch_multiq and
> act_skbedit are only for the -next!

> I'm very sorry for misleading!!

not to worry ;) Thanks again. I try last -next git after someone fix
Intel exception issue ;)
