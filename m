From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6 bind to device issue
Date: Wed, 21 Apr 2010 22:50:15 -0700 (PDT)
Message-ID: <20100421.225015.137831360.davem@davemloft.net>
References: <1271767572-5282-1-git-send-email-jolsa@redhat.com>
	<4BCDEED3.7040901@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jolsa@redhat.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34556
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752052Ab0DVFuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 01:50:10 -0400
In-Reply-To: <4BCDEED3.7040901@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 20 Apr 2010 14:13:39 -0400

> Actually, looking at this again, we might want to swap the order
> here since fl->oif should be filled-in for most link-local and
> multicast requests calling this:
> 
> 	if (fl->oif || rt6_need_strict(&fl->fl6_dst))
> 
> Just a thought, but it potentially saves a call to determine
> the scope of the address.

Yes I think we should make this change.

Jiri please respin your patch with the argument order
reversed so that we can make the inexpensive check before
the expensive one.

Thanks.
