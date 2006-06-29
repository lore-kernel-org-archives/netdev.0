From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Thu, 29 Jun 2006 16:47:32 -0700 (PDT)
Message-ID: <20060629.164732.41636454.davem@davemloft.net>
References: <20060629085111.GY1376@postel.suug.ch>
	<1151623394.8922.27.camel@jzny2>
	<20060629233933.GB14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28554
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932659AbWF2Xre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 19:47:34 -0400
To: tgraf@suug.ch
In-Reply-To: <20060629233933.GB14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 30 Jun 2006 01:39:33 +0200

> * jamal <hadi@cyberus.ca> 2006-06-29 19:23
> > I know your intent is noble in trying to save the 32 bits on 64 bit
> > machines (at least thats where your patch seems to have started) but the
> > cost:benefit ratio as i have pointed out is unreasonable. 
> 
> Did I ever claim this? You made this up right now. As of now
> it doesn't save a single bit.

Right.

>From what I can see Thomas's work allows to do correct
reference counting on the input_dev, something which is
not possible right now and is a bug.
