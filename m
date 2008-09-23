From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Machine Check Exception Re: NetDev! Please help!
Date: Tue, 23 Sep 2008 20:26:08 +0200
Message-ID: <20080923182607.GA2992@ami.dom.local>
References: <48D8DE33.6000605@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.191]:16469 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbYIWSZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 14:25:38 -0400
Received: by gv-out-0910.google.com with SMTP id e6so179253gvc.37
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 11:25:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48D8DE33.6000605@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Badalian Vyacheslav wrote, On 09/23/2008 02:16 PM:
...
> I simple hope that after divide to bands/queues and go back to network
> all packets save "First in and First Out" logic that needed in services
> like video streaming...

Of course this is aimed at, and if it's really first in per flow, and
flows are bound to devs/irqs, after hashing should be the same. But...
shit happens - e.g. recently there has been fixed a bug in the hash
which could change this order. And you should remember this default
qdisc is prioritized fifo, so you should be careful with TOS etc. 

>> sch_multiq doesn't use any params for hashing now - it uses mapping
>> in packets to separate them to different bands/queues. So, by default
>> it'll respect common hashing. You can change this using any filter with
>> act_skbedit (Documentation/networking/multiqueue.txt).
>>
>>   
> Ok! I will read all related information and rewrite all tc generate
> scripts to test it!

Do you mean net-next? I think you should first do some tests if you
really need this.

...
> not to worry ;) Thanks again. I try last -next git after someone fix
> Intel exception issue ;)

I think, maybe you could try what Ingo Molnar asked: -tip git, for now?

Jarek P.
