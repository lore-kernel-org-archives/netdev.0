From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index>
 mapping
Date: Fri, 16 Jul 2010 13:18:35 -0700 (PDT)
Message-ID: <20100716.131835.124042396.davem@davemloft.net>
References: <AANLkTinAiJJqhrro8Jlrb0WgHzDSCx_dtWXL5N9ZKUbd@mail.gmail.com>
	<20100716.130445.149851386.davem@davemloft.net>
	<AANLkTineSDEEKY-9ve2maSBmPWBxkW5XmqnHlLtIOClx@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, Chetan.Loke@netscout.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: chetanloke@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57110
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753507Ab0GPUST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 16:18:19 -0400
In-Reply-To: <AANLkTineSDEEKY-9ve2maSBmPWBxkW5XmqnHlLtIOClx@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chetan Loke <chetanloke@gmail.com>
Date: Fri, 16 Jul 2010 16:15:44 -0400

> Ok, what if, i) ifindex == 0 in the call to SIOCGIFINDEX or ii) if the
> ifindex is not found ? May be then in the else clause we could search
> using the hw-addr before bailing out ;)? This way we can avoid adding
> a new API. Still not a good idea?

I'm really not going to consider this seriously, sorry.  I've
made my position pretty clear, and gave sufficient reasons for
it.

Myself and others have also shown you several ways to fetch the
information you need, and of them netlink is probably the most
efficient, but the others work just as well.

The new interface proposals are just not a good idea.
