From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink & rhashtable status
Date: Wed, 13 May 2015 06:04:31 -0700
Message-ID: <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431495036.566.126.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513054037.GA26595@gondor.apana.org.au>
	 <1431497740.566.129.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513062038.GA26944@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:35691 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934226AbbEMNEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 09:04:34 -0400
Received: by pdbqd1 with SMTP id qd1so51176934pdb.2
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 06:04:33 -0700 (PDT)
In-Reply-To: <20150513062038.GA26944@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-13 at 14:20 +0800, Herbert Xu wrote:
> On Tue, May 12, 2015 at 11:15:40PM -0700, Eric Dumazet wrote:
> > 
> > Trick is to start about 200 threads using getaddrinfo()
> 
> When it loses the kernel socket, is it permanent or intermittent?
> 
> I'm trying to figure out whether it's the hashtable reader missing
> an entry that's there or whether the hashtable has been corrupted
> and an entry is gone forever.
> 
> Cheers,

This is permanent. We have to reboot the host.
