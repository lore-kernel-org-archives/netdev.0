From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: add support for scheduling TCP options on TCP sockets
Date: Wed, 07 May 2014 08:32:08 -0700
Message-ID: <1399476728.15399.146.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399399524-28550-1-git-send-email-octavian.purdila@intel.com>
	 <20140507.013820.1357850416047414291.davem@davemloft.net>
	 <bc98535539ef4d2c9cb6f53f85068b65@UCL-MBX03.OASIS.UCLOUVAIN.BE>
	 <20140507134620.GF4686@cpaasch-mac>
	 <906b020ccf1b4e1b98ac414147259a65@UCL-MBX03.OASIS.UCLOUVAIN.BE>
	 <20140507141108.GG4686@cpaasch-mac>
	 <CAE1zot+L0WVdxSRX7gUSU7V52X0qdk2mTrsXaCAbGmPRu6=Yog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Octavian Purdila <octavian.purdila@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:57302 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbaEGPcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 11:32:35 -0400
Received: by mail-pd0-f181.google.com with SMTP id w10so1167246pde.40
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 08:32:35 -0700 (PDT)
In-Reply-To: <CAE1zot+L0WVdxSRX7gUSU7V52X0qdk2mTrsXaCAbGmPRu6=Yog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-07 at 18:17 +0300, Octavian Purdila wrote:

> 
> That would require adding a new field to sk_buff to keep track of how
> much we need to copy in pskb_copy. Fortunately it seems it has some
> holes we could use.
> 
> David, does that seem reasonable?

MPTCP and/or Minion could be implemented in user land, with a generic
infrastructure in the kernel to directly pass raw packets once demux
has been done by the kernel.

Large CDN cant always assume multi paths to hit a particular destination
can all originate from a single host in the datacenter.

MPTCP has this hard assumption from day one.

Our team try to focus on making TCP better, we believe all these
experimental features do not belong to the kernel yet.
