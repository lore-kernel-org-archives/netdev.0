From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V6 0/2] qdisc: bulk dequeue support
Date: Fri, 03 Oct 2014 13:57:49 -0700
Message-ID: <1412369869.17245.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001203345.3321.99675.stgit@dragon>
	 <20141003.123806.183331913071081861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, therbert@google.com,
	hannes@stressinduktion.org, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:45897 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbaJCU5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 16:57:22 -0400
Received: by mail-pd0-f180.google.com with SMTP id fp1so185166pdb.25
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 13:57:22 -0700 (PDT)
In-Reply-To: <20141003.123806.183331913071081861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-03 at 12:38 -0700, David Miller wrote:
> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Wed, 01 Oct 2014 22:35:31 +0200
> 
> > This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
> > from the qdisc layer, to implement dequeue bulking.
> 
> Series applied, thanks for all of your hard work!


I thinks its possible to make all validate_xmit_skb() calls outside of
qdisc lock.  GSO segmentation of TX checksuming should not prevent other
cpus from queueing other skbs in the qdisc.

I will spend some time on this.
