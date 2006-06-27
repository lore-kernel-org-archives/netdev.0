From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Tue, 27 Jun 2006 09:07:50 -0400
Message-ID: <1151413670.6516.57.camel@jzny2>
References: <20060626.104654.98552111.davem@davemloft.net>
	 <20060626184424.GT1376@postel.suug.ch> <44A05FE0.7070203@trash.net>
	 <44A0647A.1070209@trash.net> <20060626145446.948105000@postel.suug.ch>
	 <20060626145515.769648000@postel.suug.ch> <44A0138F.8050208@trash.net>
	 <20060626.104654.98552111.davem@davemloft.net>
	 <20060626184424.GT1376@postel.suug.ch> <44A05FE0.7070203@trash.net>
	 <20060627100309.GU1376@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:59328 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932111AbWF0NHx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 09:07:53 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FvDIJ-0001zs-NW
	for netdev@vger.kernel.org; Tue, 27 Jun 2006 09:07:55 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060627100309.GU1376@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-27-06 at 12:03 +0200, Thomas Graf wrote:
> * Patrick McHardy <kaber@trash.net> 2006-06-27 00:29
> > Doesn't sound too silly (actually quite nifty in my opinion),
> > but I'm not sure I understand correctly, binding to ifb doesn't
> > work since it changes both skb->dev and skb->input_dev.
> 
> I don't understand this concern. So far the mirred action
> updates iif but that can be made configurable.
> 

I am reading the thread backwards, so i may miss some of the obvious.
I also dont remember the exact discussion we had - but the consensus was
to leave the field setting as is.
Note the meta-setter (been sitting on it for too long) also set the
input_dev.

BTW, in regards to the VLANs, what is wrong with using the
netdev->iflink to figure the real device? 

cheers,
jamal

