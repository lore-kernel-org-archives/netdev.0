From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/6] sched: Eliminate use of flow_keys in
 sch_sfq
Date: Mon, 02 Mar 2015 11:43:17 -0800
Message-ID: <1425325397.5130.117.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
	 <1425247789-21211-7-git-send-email-therbert@google.com>
	 <1425257932.5130.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx-gAq=knRnf73qrOKuWy=WVaHvq2Vzb8RC39p81WBXZ8Q@mail.gmail.com>
	 <CA+mtBx-Bhewd6Ez4OotWEhxvVO8rrOieWCGAnMa9vfhTbzj=yg@mail.gmail.com>
	 <1425324483.5130.115.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx8sFBV4hFkdnvChuO0UaoN=XHKgVhreM5GwQXXgR9ARvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:40140 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753948AbbCBTnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 14:43:19 -0500
Received: by igal13 with SMTP id l13so20346648iga.5
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 11:43:19 -0800 (PST)
In-Reply-To: <CA+mtBx8sFBV4hFkdnvChuO0UaoN=XHKgVhreM5GwQXXgR9ARvg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-02 at 11:34 -0800, Tom Herbert wrote:

> Spraying would be quite easy by modulating txhash from TCP and using
> either  UDP encapsulation like GUE or IPv6 flow labels. Only problem
> is that this would constantly be changing rxhash at the receiver for
> the connection, although flow labels might 'just work' with IPv6
> Toeplitz in NICs.

When I said 'regular IPv4/tcp traffic' this did not include any added
encapsulation.

Most NIC are not able to properly offload TCP (TSO) with such
encapsulations.
