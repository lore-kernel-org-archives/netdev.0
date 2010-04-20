From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Tue, 20 Apr 2010 16:38:53 -0700 (PDT)
Message-ID: <20100420.163853.258272672.davem@davemloft.net>
References: <1271775421.7895.19.camel@edumazet-laptop>
	<20100420.144106.118596093.davem@davemloft.net>
	<v2s412e6f7f1004201635m5258e777oac49fea8f9625bcf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, franco@lastsummer.de, therbert@google.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55671
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752004Ab0DTXis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 19:38:48 -0400
In-Reply-To: <v2s412e6f7f1004201635m5258e777oac49fea8f9625bcf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 21 Apr 2010 07:35:48 +0800

> On Wed, Apr 21, 2010 at 5:41 AM, David Miller <davem@davemloft.net> wrote:
>> Eric, do you remember that "TCP friends" rough patch I sent you last
>> year that essentailly made TCP sockets over loopback behave like
>> AF_UNIX ones and just queue the SKBs directly to the destination
>> socket without doing any protocol work?
> 
> I think it will break some benchmark tools.

Other systems already do this optimization, so if things break, this
breakage is already pervasive.

We should be able to tell people that they can use TCP solely in their
applications and it will perform optimally regardless of transport.

People already code their applications this way, and ignoring
this issue would just makes us stupid.
