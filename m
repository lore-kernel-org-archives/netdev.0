From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/5] bridge - introduce via_phys_dev feature
Date: Fri, 26 Feb 2010 11:01:15 -0800 (PST)
Message-ID: <20100226.110115.229233177.davem@davemloft.net>
References: <20100226100102.0d52c6e9@nehalam>
	<20100226.100800.116618587.davem@davemloft.net>
	<20100226103003.097c39ec@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, gorcunov@gmail.com, bridge@linux-foundation.org,
	netdev@vger.kernel.org, den@openvz.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59992
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965631Ab0BZTA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 14:00:57 -0500
In-Reply-To: <20100226103003.097c39ec@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 26 Feb 2010 10:30:03 -0800

> On Fri, 26 Feb 2010 10:08:00 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <shemminger@linux-foundation.org>
>> Date: Fri, 26 Feb 2010 10:01:02 -0800
>> 
>> > TCP connections are never really bound to device. TCP routing is
>> > flexible; if packets can get through, it doesn't care.
>> 
>> I think he might be talking about SO_BINDTODEVICE
> 
> What application does that with TCP?

Any application that would like to, it's been supported from day one.

In fact I bet there are more TCP applications that support
SO_BINDTODEVICE than UDP ones.
