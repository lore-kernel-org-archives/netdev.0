From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 1/2] Traffic control cgroups subsystem
Date: Wed, 10 Sep 2008 17:09:49 -0700
Message-ID: <6599ad830809101709k5bf10e6y2399235c68e59548@mail.gmail.com>
References: <Pine.LNX.4.64.0809101040280.7050@ranjit.corp.google.com>
	 <20080910220115.GH20815@postel.suug.ch>
	 <166fe7950809101556q61cb7e30m2d5e758304618f61@mail.gmail.com>
	 <6599ad830809101604o71b2fb82k2aca1eb0fd8ab6d8@mail.gmail.com>
	 <20080910232413.GJ20815@postel.suug.ch>
	 <6599ad830809101631q51371f75w2ab9f73ef2414f90@mail.gmail.com>
	 <20080910234523.GK20815@postel.suug.ch>
	 <6599ad830809101651u79a0efb7y8fa7288de6e48c8a@mail.gmail.com>
	 <20080911000726.GM20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ranjit Manomohan" <ranjitm@google.com>, davem@davemloft.net,
	akpm@linux-foundation.org, kaber@trash.net, lizf@cn.fujitsu.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:12447 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753192AbYIKAKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 20:10:00 -0400
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id m8B09oZm012768
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 01:09:50 +0100
Received: from rv-out-0708.google.com (rvbf25.prod.google.com [10.140.82.25])
	by spaceape9.eur.corp.google.com with ESMTP id m8B08oqC010927
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 17:09:50 -0700
Received: by rv-out-0708.google.com with SMTP id f25so86142rvb.26
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 17:09:49 -0700 (PDT)
In-Reply-To: <20080911000726.GM20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2008 at 5:07 PM, Thomas Graf <tgraf@suug.ch> wrote:
>> Isn't a very large fraction of outgoing network traffic driven from
>> net_tx_action(), which doesn't execute in the context of the sending
>> process? Or am I missing something?
>
> net_tx_action() dequeues from the qdisc. The classification is done
> before the packets is enqueued onto the qdisc.

Ah, good point.

Thanks,

Paul
