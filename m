From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/4] net: vrf: call netdev_lockdep_set_classes()
Date: Wed, 8 Jun 2016 19:49:20 -0600
Message-ID: <80f2d58b-4ad7-b367-2b46-dbf510a3e2fc@cumulusnetworks.com>
References: <1465430127-22993-1-git-send-email-edumazet@google.com>
 <1465430127-22993-2-git-send-email-edumazet@google.com>
 <31939b76-efa5-f1dd-3a8b-92d9343df7ee@cumulusnetworks.com>
 <CANn89iLr_H+hdti2wHzjP3P64oRiATTRe-usNkKjTu6XizNBHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:32804 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161644AbcFIBtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 21:49:23 -0400
Received: by mail-pf0-f179.google.com with SMTP id y124so8091945pfy.0
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 18:49:23 -0700 (PDT)
In-Reply-To: <CANn89iLr_H+hdti2wHzjP3P64oRiATTRe-usNkKjTu6XizNBHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/16 7:43 PM, Eric Dumazet wrote:
> For this one, it looks vrf misses the _xmit_lock lockdep support.
>
> We might need to factorize the code found for example in
> bond_set_lockdep_class_one()
>
> Have you run lockdep before ? Strange that these issues were not
> spotted earlier.

Standard config for non-performance builds has the locking and rcu 
debugs enabled. You posted the patches on Jun 6; this morning was the 
first build with them and first run hit it.
