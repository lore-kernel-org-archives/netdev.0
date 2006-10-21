From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [patch 2/9] IPv6/DCCP: fix memory leak in dccp_v6_do_rcv()
Date: Sat, 21 Oct 2006 13:39:37 -0300
Message-ID: <39e6f6c70610210939v14bdd099r340fa9fe5da1f24f@mail.gmail.com>
References: <200610202143.k9KLh25B003765@shell0.pdx.osdl.net>
	 <20061020.192508.38711169.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, jesper.juhl@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:25553 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161486AbWJUQjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Oct 2006 12:39:39 -0400
Received: by nf-out-0910.google.com with SMTP id c2so1782074nfe
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2006 09:39:37 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061020.192508.38711169.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/06, David Miller <davem@davemloft.net> wrote:
> From: akpm@osdl.org
> Date: Fri, 20 Oct 2006 14:43:02 -0700
>
> > (akpm: does opt_skb actually do anything?)
>
> This is a clone of similar code in net/ipv6/tcp_ipv6.c, it's just
> missing the bits at label "ipv6_pktoptions:" :-)
>
> No offence to the original patch, it's correct, but I'm going to fix
> this by making the dccp ipv6 logic match the code it was copied from
> in tcp_ipv6.c as much as possible.
>
> Thanks a lot for finding this leak Jesper.

Thanks everybody!

- Arnaldo
