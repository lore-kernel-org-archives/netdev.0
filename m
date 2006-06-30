From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 17:35:05 -0400
Message-ID: <1151703305.5270.311.camel@jzny2>
References: <1151625826.8922.58.camel@jzny2>
	 <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2>
	 <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2>
	 <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2>
	 <20060630163229.GH14627@postel.suug.ch>
	 <20060630171348.GI14627@postel.suug.ch> <1151701767.5270.289.camel@jzny2>
	 <20060630212047.GP14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:22987 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S933140AbWF3VfK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 17:35:10 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FwQdt-0007FC-4T
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 17:35:13 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630212047.GP14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 23:20 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-30 17:09
> > the ref inside the else below after changing input_dev 
> 
> A non-existant iif is already equivalent to !iif since it jumps
> into the same branch. 

I thought 0 was a valid iif as Ben G was pointing - if it is not, you
are right. 

> Grabing a reference is completely pointless,
> the netdevice represented by skb->iif is at this point until the
> packet gets queued covered by a reference taken in netif_rx().

You have to consider that this could happen at both ingress and egress.

cheers,
jamal

