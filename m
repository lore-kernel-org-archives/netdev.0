From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] [NET] One NET_INC_STATS() could be NET_INC_STATS_BH in tcp_v4_err()
Date: Fri, 20 Oct 2006 11:21:40 -0300
Message-ID: <39e6f6c70610200721p26ec4eceld26dda8a5beb3dab@mail.gmail.com>
References: <200610180938.39175.dada1@cosmosbay.com>
	 <200610191257.42549.dada1@cosmosbay.com>
	 <200610191745.26514.dada1@cosmosbay.com>
	 <20061020.002243.48819436.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:58724 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S2992620AbWJTOVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 10:21:41 -0400
Received: by wx-out-0506.google.com with SMTP id h28so982644wxd
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2006 07:21:41 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061020.002243.48819436.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/06, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 19 Oct 2006 17:45:26 +0200
>
> > I believe this NET_INC_STATS() call can be replaced by  NET_INC_STATS_BH(), a
> > little bit cheaper.
> >
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>
> Applied, although I hope tcp_v4_err() never becomes a fast path :-)

I'll queue a cset in my net-2.6 tree to do the equivalent for dccp_v4_err() :-)

- Arnaldo
