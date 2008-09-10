From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 1/2] Traffic control cgroups subsystem
Date: Wed, 10 Sep 2008 16:51:55 -0700
Message-ID: <6599ad830809101651u79a0efb7y8fa7288de6e48c8a@mail.gmail.com>
References: <Pine.LNX.4.64.0809101040280.7050@ranjit.corp.google.com>
	 <20080910220115.GH20815@postel.suug.ch>
	 <166fe7950809101556q61cb7e30m2d5e758304618f61@mail.gmail.com>
	 <6599ad830809101604o71b2fb82k2aca1eb0fd8ab6d8@mail.gmail.com>
	 <20080910232413.GJ20815@postel.suug.ch>
	 <6599ad830809101631q51371f75w2ab9f73ef2414f90@mail.gmail.com>
	 <20080910234523.GK20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ranjit Manomohan" <ranjitm@google.com>, davem@davemloft.net,
	akpm@linux-foundation.org, kaber@trash.net, lizf@cn.fujitsu.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:9607 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbYIJXxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 19:53:23 -0400
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id m8ANrH1h023964
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 00:53:17 +0100
Received: from yx-out-1718.google.com (yxi3.prod.google.com [10.190.3.3])
	by spaceape12.eur.corp.google.com with ESMTP id m8ANrGkn030254
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 16:53:16 -0700
Received: by yx-out-1718.google.com with SMTP id 3so35424yxi.80
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 16:53:16 -0700 (PDT)
In-Reply-To: <20080910234523.GK20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2008 at 4:45 PM, Thomas Graf <tgraf@suug.ch> wrote:
>
> That's argueable I guess. Likely or not, it doesn't make sense to
> add such restrictions if not required, especially not when it is
> trivial to just look at the cgroup of the task directly.

Isn't a very large fraction of outgoing network traffic driven from
net_tx_action(), which doesn't execute in the context of the sending
process? Or am I missing something?

You claimed "In the most common case, the packet is not queued before
it hits the qdisc so this takes away a lot of complexity and is very
fast but should still be sufficient.". But is that really true on a
system where the network is busy? (Which is after all exactly the case
where you care about accurate traffic accounting/policing)

Paul
