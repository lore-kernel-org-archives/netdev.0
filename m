From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 2/4] ipv6: unify conntrack reassembly expire code with
 standard one
Date: Wed, 19 Sep 2012 17:12:46 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1209191659150.12601@ask.diku.dk>
References: <1348023011-16195-1-git-send-email-amwang@redhat.com>
 <1348023011-16195-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	=?UTF-8?q?Michal=20Kube=C4=8Dek?= <mkubecek@suse.cz>,
	David Miller <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:36154 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755229Ab2ISPLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 11:11:16 -0400
In-Reply-To: <1348023011-16195-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Sep 2012, Cong Wang wrote:

[cut]
> With this patch applied, I can see ICMP Time Exceeded sent
> from the receiver when the sender sent out 3/4 fragmented
> IPv6 UPD packet.

Typo "UPD" -> "UDP"

If people want to redo the IPv6 UDP fragment tests, they can use my scapy 
script, and comment out sending the last fragment:
  https://github.com/netoptimizer/network-testing/blob/master/scapy/ipv6_fragment01.py

Another thing, could you please "mark"/put the version of the patch in the 
subject line, like:

  [PATCH V4 2/4] ipv6: ...

This makes it easier, to follow on which version of the patch people are 
replying to.

With git send-email I think you have to do:

   git send-email --subject-prefix="PATCH V4"

And with stg (stacked git) I usually do:

   stg mail --version "V4" --to netdev ...

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
