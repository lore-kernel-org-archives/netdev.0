From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next] net: pktgen: packet bursting via
 skb->xmit_more
Date: Fri, 26 Sep 2014 09:06:30 -0700
Message-ID: <1411747590.16953.132.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
	 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411746270.16953.130.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuxduBWxRggN8b9yxQPb-0zVkpM5HhRYGh1Bdp6nm7c2eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:44331 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754531AbaIZQGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 12:06:31 -0400
Received: by mail-pd0-f174.google.com with SMTP id g10so12528446pdj.19
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 09:06:31 -0700 (PDT)
In-Reply-To: <CAMEtUuxduBWxRggN8b9yxQPb-0zVkpM5HhRYGh1Bdp6nm7c2eQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-26 at 08:59 -0700, Alexei Starovoitov wrote:

> 
> oh. thanks for testing! That makes sense.
> I don't think I can find bnx2x around to double check this.
> Do you mind applying this fix and resubmitting with two sob?
> This one was rfc anyway :)

Yes, I'll also provide the bnx2x patch to support skb->xmit_more.

Thanks
