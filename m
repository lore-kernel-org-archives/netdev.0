From: Milan Kocian <milon@wq.cz>
Subject: Re: [PATCH 1/1] ipv6: corrects sended rtnetlink message
Date: Wed, 12 Sep 2007 16:50:30 +0200
Message-ID: <20070912145030.GA29748@wq.cz>
References: <20070815143322.GA25640@wq.cz> <20070821.002058.102575162.davem@davemloft.net> <20070829215119.GB15856@wq.cz> <20070906104711.GV18480@postel.suug.ch> <20070906210550.GA13542@wq.cz> <20070907101137.GX18480@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-sitel.lam.cz ([212.71.129.172]:44411 "EHLO nt.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S966609AbXILOuk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 10:50:40 -0400
Content-Disposition: inline
In-Reply-To: <20070907101137.GX18480@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Now I ignore (RTM_DELLINK && ifi_family==AF_INET6) :-). But it's only workaround
> > till next change. 
> 
> That's also correct, pure netdevice notification will always be sent
> with the ifi_family set to AF_UNSPEC.
> 
It's essential property, I missed. Thanks.

> > Hard to find it. I can try to look at other routing sw (probably most using it)
> > about handling with RTM_DELLINK.
> > Howerer when was made change from RTM_NEWLINK to RTM_DELLINK without protests,
> > we can try remove message :-)
> 
> I'd give the USAGI software tree a short peek, if there was a specific
> reason for adding this notification in the first place, the software is
> most probably found in that tree.

However I still think that this notitfication is redundant. I tried to look
at XORP, bird, USAGI , quagga and to see RTM_DELLINK handling. And imho
nobody depends on RTM_DELLINK message from ipv6.

regards,

-- 
Milan Kocian
