From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: pktgen: packet bursting via skb->xmit_more
Date: Tue, 30 Sep 2014 17:18:45 -0700
Message-ID: <CAMEtUuyvEWc2Pph2hPaQ4f-6UXDxo9GnpUX6uA13=SEvm_QN9Q@mail.gmail.com>
References: <1412121820-28633-1-git-send-email-ast@plumgrid.com>
	<1412122303.16704.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35454 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbaJAASq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 20:18:46 -0400
Received: by mail-wi0-f178.google.com with SMTP id cc10so112297wib.17
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 17:18:45 -0700 (PDT)
In-Reply-To: <1412122303.16704.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014 at 5:11 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> It seems you dont really need @burst_cnt or @more in this function.

excellent suggestion! That is indeed much easier to read. will respin.
