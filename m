From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] veth: extend features to support tunneling
Date: Fri, 25 Oct 2013 21:13:53 -0700
Message-ID: <1382760833.4032.34.camel@edumazet-glaptop.roam.corp.google.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	 <1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	 <1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131025.181809.348808013109842304.davem@davemloft.net>
	 <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
	 <1382743502.4032.6.camel@edumazet-glaptop.roam.corp.google.com>
	 <1382748742.4032.24.camel@edumazet-glaptop.roam.corp.google.com>
	 <1382750703.4032.32.camel@edumazet-glaptop.roam.corp.google.com>
	 <CAMEtUuwgDpLFMj0DNx+c4QZz573rgmLiNcZOmHgou2A3684Shw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:64246 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab3JZEN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 00:13:57 -0400
Received: by mail-ee0-f50.google.com with SMTP id l10so2406530eei.9
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 21:13:56 -0700 (PDT)
In-Reply-To: <CAMEtUuwgDpLFMj0DNx+c4QZz573rgmLiNcZOmHgou2A3684Shw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-25 at 19:22 -0700, Alexei Starovoitov wrote:
> On Fri, Oct 25, 2013 at 6:25 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > While investigating on a recent vxlan regression, I found veth
> > was using a zero features set for vxlan tunnels.
> 
> oneliner can be better :)

Yes, I'll post the gso fix as well, of course ;)

> 
> > We have to segment GSO frames, copy the payload, and do the checksum.
> >
> > This patch brings a ~200% performance increase
> >
> > We probably have to add hw_enc_features support
> > on other virtual devices.
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Alexei Starovoitov <ast@plumgrid.com>
> > ---
> 
> iperf over veth with gre/vxlan tunneling is now ~4Gbps. 20x gain as advertised.
> Thanks!

Wow, such a difference might show another bug somewhere else...

Thanks !
