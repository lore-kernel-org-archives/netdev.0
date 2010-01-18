From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] improve netem reorder flexibility
Date: Sun, 17 Jan 2010 18:56:36 -0800 (PST)
Message-ID: <20100117.185636.163664050.davem@davemloft.net>
References: <20091221095407.5430a630@nehalam>
	<20100116.014654.69913255.davem@davemloft.net>
	<201001171311.19278.christian.samsel@rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: christian.samsel@rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33821
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754543Ab0ARC40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 21:56:26 -0500
In-Reply-To: <201001171311.19278.christian.samsel@rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Samsel <christian.samsel@rwth-aachen.de>
Date: Sun, 17 Jan 2010 13:11:18 +0100

> Am Samstag, 16. Januar 2010 10:46:54 schrieb David Miller:
>> This is a complete mess, and we need to sort it out before we think
>> about changing the size of qopt at this point.
>> 
> Just to state this clearly, by cleaning up the mess you mean switching netem 
> completely over to netlink attributes? 

I think the only way we can proceed is to keep the current qopt
structure static, and only add things using new attributes.

I would also suggest that we make sch_netem.c strictly require a
specific size for the structure.  And before anyone says that will
break something, it's much better than what we have now which is
random, silent, dropping of attributes.
