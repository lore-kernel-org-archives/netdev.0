From: David Miller <davem@davemloft.net>
Subject: Re: Generalizing mmap'ed sockets
Date: Fri, 19 Nov 2010 13:52:13 -0800 (PST)
Message-ID: <20101119.135213.15239226.davem@davemloft.net>
References: <AANLkTi=WF2hAGAufv_Anc=b=Fm2WOpOMOv1UrDRvaTHp@mail.gmail.com>
	<4CE6ED09.70602@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34138
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757303Ab0KSVvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 16:51:48 -0500
In-Reply-To: <4CE6ED09.70602@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 19 Nov 2010 13:32:57 -0800

> I suppose then one would be able to track the consumer pointer (on tx)
> to "know" that certain data had been ACKed by the remote?  For TCP
> anyway - and assuming there wouldn't be a case where TCP might copy
> the data out of the ring and assert "completion."

Yes, that's implicit in his design, the kernel manages the consumer
pointer in the ring and this is how userspace can see when ring entries
are reusable.
