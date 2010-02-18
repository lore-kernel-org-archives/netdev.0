From: David Miller <davem@davemloft.net>
Subject: Re: regression due to "flush SAD/SPD generate false events"
Date: Thu, 18 Feb 2010 14:27:35 -0800 (PST)
Message-ID: <20100218.142735.230862605.davem@davemloft.net>
References: <20100218185510.GA18829@x200>
	<1266526416.3879.109.camel@bigi>
	<1266529558.3879.121.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36770
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758550Ab0BRW1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 17:27:19 -0500
In-Reply-To: <1266529558.3879.121.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Thu, 18 Feb 2010 16:45:58 -0500

> The two options are: 1) Restore old behavior just for pfkey
> where bogus event is sent always or 2) return -ESRCH as I
> have done in the last patch.
> I think #2 is more accurate. But if that is going to break
> existing scripts then #1 is the way to go.
> 
> Thoughts?

Let's see how #2 works out, if we get any more breakage
cases reported then we'll have to revert again and go with
#1.
