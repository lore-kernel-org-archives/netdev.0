From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Thu, 29 Jun 2006 20:08:19 -0400
Message-ID: <1151626099.8922.64.camel@jzny2>
References: <20060629085111.GY1376@postel.suug.ch>
	 <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch>
	 <20060629.164732.41636454.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:49622 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S933118AbWF3AIW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 20:08:22 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fw6Yd-00089g-QZ
	for netdev@vger.kernel.org; Thu, 29 Jun 2006 20:08:27 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060629.164732.41636454.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-29-06 at 16:47 -0700, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Fri, 30 Jun 2006 01:39:33 +0200
> 
> > * jamal <hadi@cyberus.ca> 2006-06-29 19:23
> > > I know your intent is noble in trying to save the 32 bits on 64 bit
> > > machines (at least thats where your patch seems to have started) but the
> > > cost:benefit ratio as i have pointed out is unreasonable. 
> > 
> > Did I ever claim this? You made this up right now. As of now
> > it doesn't save a single bit.
> 
> Right.
> 

What am i missing?
on 64bit machine, does it not save 32 bits to use an ifindex as opposed
to the pointer?

> From what I can see Thomas's work allows to do correct
> reference counting on the input_dev, something which is
> not possible right now and is a bug.

Yes, it is a bug, but:
dev_hold/put dont work anymore? why do you need an ifindex instead?

cheers,
jamal

