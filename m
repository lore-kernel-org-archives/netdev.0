From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM] export SAD info
Date: Thu, 26 Apr 2007 00:10:50 -0700 (PDT)
Message-ID: <20070426.001050.97294686.davem@davemloft.net>
References: <1177515761.9923.3.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40533
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933327AbXDZHK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:10:57 -0400
In-Reply-To: <1177515761.9923.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 25 Apr 2007 11:42:41 -0400

> [XFRM] export SAD info
> 
> On a system with a lot of SAs, counting SAD entries chews useful
> CPU time since you need to dump the whole SAD to user space;
> i.e something like ip xfrm state ls | grep -i src | wc -l
> I have seen taking literally minutes on a 40K SAs when the system
> is swapping.
> With this patch, some of the SAD info (that was already being tracked)
> is exposed to user space. i.e you do:
> ip xfrm state count
> And you get the count; you can also pass -s to the command line and
> get the hash info.
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied, thanks Jamal.
