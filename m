From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 08:33:39 -0700
Message-ID: <1412955219.9362.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>
	 <20141010035840.21428.359.stgit@ahduyck-workstation.home>
	 <20141010.004708.1975127853551765914.davem@davemloft.net>
	 <5437F072.5060502@redhat.com>
	 <063D6719AE5E284EB5DD2968C1650D6D174C858B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "'alexander.h.duyck@redhat.com'" <alexander.h.duyck@redhat.com>,
	David Miller <davem@davemloft.net>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:53459 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbaJJPdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 11:33:41 -0400
Received: by mail-pa0-f54.google.com with SMTP id ey11so1973563pad.13
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 08:33:41 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174C858B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-10 at 14:57 +0000, David Laight wrote:

> I think there is code to copy the IP and TCP headers to aligned memory
> before they are parsed.

There is no such thing. You are here on netdev list, please read the
code before doing such claims.

> ...
> > 
> > The problem is the igb / ixgbe / fm10k hardware doesn't have a means of
> > inserting padding from its side...
> 
> Shoot the hardware engineers.
> 
> You aren't going to get the performance you expect from a 10Ge card
> unless the rx buffers are 'correctly' aligned.

That is simply not true on current x86 cpus. They simply dont care at
all.

You cannot blame Intel for other arches.
