From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V6 0/2] qdisc: bulk dequeue support
Date: Fri, 03 Oct 2014 15:15:35 -0700
Message-ID: <1412374535.17245.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001203345.3321.99675.stgit@dragon>
	 <20141003.123806.183331913071081861.davem@davemloft.net>
	 <1412369869.17245.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141003.145647.1980640682969765484.davem@davemloft.net>
	 <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, therbert@google.com,
	hannes@stressinduktion.org, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:42473 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbaJCWPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:15:06 -0400
Received: by mail-pa0-f41.google.com with SMTP id eu11so2168767pac.28
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:15:06 -0700 (PDT)
In-Reply-To: <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-03 at 14:57 -0700, Eric Dumazet wrote:
> On Fri, 2014-10-03 at 14:56 -0700, David Miller wrote:
> 
> > I completely agree, and I sort of intended this to happen when
> > I split all the code into that new function.
> > 
> >   GSO segmentation of TX checksuming should not prevent other
> > > cpus from queueing other skbs in the qdisc.
> > > 
> > > I will spend some time on this.
> > 
> > Thanks!
> 
> I just did my first reboot, will make sure everything is working well
> before sending the patch ;)

This is awesome...

40Gb rate, with TSO=on or TSO=off, it does not matter anymore.
