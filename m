From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V6 0/2] qdisc: bulk dequeue support
Date: Fri, 03 Oct 2014 14:57:57 -0700
Message-ID: <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001203345.3321.99675.stgit@dragon>
	 <20141003.123806.183331913071081861.davem@davemloft.net>
	 <1412369869.17245.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141003.145647.1980640682969765484.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, therbert@google.com,
	hannes@stressinduktion.org, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:45753 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521AbaJCV52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 17:57:28 -0400
Received: by mail-pd0-f181.google.com with SMTP id z10so255074pdj.12
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 14:57:28 -0700 (PDT)
In-Reply-To: <20141003.145647.1980640682969765484.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-03 at 14:56 -0700, David Miller wrote:

> I completely agree, and I sort of intended this to happen when
> I split all the code into that new function.
> 
>   GSO segmentation of TX checksuming should not prevent other
> > cpus from queueing other skbs in the qdisc.
> > 
> > I will spend some time on this.
> 
> Thanks!

I just did my first reboot, will make sure everything is working well
before sending the patch ;)
