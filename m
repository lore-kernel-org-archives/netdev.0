From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: What's the status of TCP friends?
Date: Mon, 17 Mar 2014 21:03:20 -0700
Message-ID: <1395115400.9114.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140316090744.GA14572@gmail.com>
	 <1394978619.9668.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140317031605.GA22502@gmail.com>
	 <20140318012120.GG12291@order.stressinduktion.org>
	 <20140318031346.GA5142@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>, Li Yu <bingtian.ly@taobao.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Brutus Curtis <brutus@google.com>,
	Weiping Pan <panweiping3@gmail.com>, tmorvai@gmail.com
To: Zheng Liu <gnehzuil.liu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:62566 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbaCREDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 00:03:32 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so6626291pbc.7
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 21:03:32 -0700 (PDT)
In-Reply-To: <20140318031346.GA5142@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-18 at 11:13 +0800, Zheng Liu wrote:

> That sounds great!  But it might not satisfy our requirement.  If we use
> AF_UNIX our program will not be deployed on two servers.  Meanwhile
> AF_INET has been applied in our program to communicate with other
> clients.  So DGRAM seems that it is not a good idea.  Now our program
> needs a IPC mechansim that can commnucate between two servers and
> provide a high performance when two processes are run on the same
> server.  That is the reason why I am interested in TCP friends.  :)

TCP friends is another layer added into TCP stack, for what ?

Improving performance for lazy applications ?

Really, if you cared about performance, you would have added a way to
use fast IPC if available.

TCP friends will still be slower than the available IPC mechanisms, by
an order of magnitude.

So instead of spending time on this TCP friends dream, I think you
should focus on existing and supported mechanisms.

I for example could add zerocopy support to AF_UNIX, if you think its
worth it.
