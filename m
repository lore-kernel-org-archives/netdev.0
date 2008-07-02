From: Martin Devera <devik@cdi.cz>
Subject: Re: [RFC]: net-sched 00/05: dynamically sized class hashes
Date: Wed, 02 Jul 2008 08:54:39 +0200
Message-ID: <486B262F.2040108@cdi.cz>
References: <20080701143410.26309.45560.sendpatchset@localhost.localdomain> <20080701.195050.177373433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wifcom.cz ([89.185.251.8]:43587 "EHLO wifcom.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755795AbYGBGy6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 02:54:58 -0400
In-Reply-To: <20080701.195050.177373433.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue,  1 Jul 2008 16:34:11 +0200 (MEST)
> 
>> Only RFC at this point because they haven't been tested thoroughly yet
>> and depend on the filter destruction fixes I sent this morning, but any
>> review (especially of 4/5, the htb_delete changes) is welcome.
> 
> These patches look fine to me.
> 
> I haven't investigated the correctness of the details of patch
> 4 yet, sorry :-)  Maybe someone else will be able to.
> 

It seems ok to me. I even can't remember why to destroy in class order :-)
Interestingly, once you do this patch then children/siblings list-heads
are used only in htb_parent_last_child and to detect empty class.
Thus we could remove children/siblings lists altogether ane keep only
children counter.
I can't believe it is so simple, what do you think, Patrick ?

Martin
