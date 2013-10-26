From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] veth: extend features to support tunneling
Date: Fri, 25 Oct 2013 19:22:23 -0700
Message-ID: <CAMEtUuwgDpLFMj0DNx+c4QZz573rgmLiNcZOmHgou2A3684Shw@mail.gmail.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	<1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	<1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	<20131025.181809.348808013109842304.davem@davemloft.net>
	<CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
	<1382743502.4032.6.camel@edumazet-glaptop.roam.corp.google.com>
	<1382748742.4032.24.camel@edumazet-glaptop.roam.corp.google.com>
	<1382750703.4032.32.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:49862 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254Ab3JZCWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 22:22:24 -0400
Received: by mail-we0-f175.google.com with SMTP id t61so4483424wes.6
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 19:22:23 -0700 (PDT)
In-Reply-To: <1382750703.4032.32.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 25, 2013 at 6:25 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> While investigating on a recent vxlan regression, I found veth
> was using a zero features set for vxlan tunnels.

oneliner can be better :)

> We have to segment GSO frames, copy the payload, and do the checksum.
>
> This patch brings a ~200% performance increase
>
> We probably have to add hw_enc_features support
> on other virtual devices.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> ---

iperf over veth with gre/vxlan tunneling is now ~4Gbps. 20x gain as advertised.
Thanks!
