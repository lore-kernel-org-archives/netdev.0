From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] dql: dql_queued() should write first to reduce
 bus transactions
Date: Fri, 26 Sep 2014 10:47:32 +0200
Message-ID: <20140926104732.625b4141@redhat.com>
References: <20140924160932.9721.56450.stgit@localhost>
	<20140924161047.9721.43080.stgit@localhost>
	<1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140924195831.6fb91051@redhat.com>
	<CA+mtBx8s63TDe1XS7TzfscwhiRCgyeLkKLz2p-4et1erX0-dUQ@mail.gmail.com>
	<1411586550.15395.46.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411611140.16953.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411688409.16953.64.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411711496.16953.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Toke =?UTF-8?B?SMO4aWxh?= =?UTF-8?B?bmQtSsO4cmdlbnNlbg==?=
	<toke@toke.dk>, Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41948 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753972AbaIZIr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 04:47:58 -0400
In-Reply-To: <1411711496.16953.92.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Sep 2014 23:04:56 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

[...]
> 
> It turned out the problem was caused by compiler trying to be
> smart, but involving a bad MESI transaction :
>
[...] 
> 
> I got an incredible 10 % gain [1] by making sure cpu do not attempt
> to get the cache line in Shared mode, but directly requests for
> ownership.
[...]
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

I'm very impressed - thank you Eric for finding this!!!

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
