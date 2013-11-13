From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] tcp: tsq: restore minimal amount of queueing
Date: Wed, 13 Nov 2013 14:41:25 -0800
Message-ID: <1384382485.28458.133.camel@edumazet-glaptop2.roam.corp.google.com>
References: <8761s0cqhh.fsf@natisbad.org>
	 <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
	 <87y54u59zq.fsf@natisbad.org>
	 <1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384353174.28458.110.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8738n0ngq3.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Sujith Manoharan <sujith@msujith.org>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:57744 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992Ab3KMWla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 17:41:30 -0500
Received: by mail-pa0-f50.google.com with SMTP id hz1so1131841pad.9
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 14:41:29 -0800 (PST)
In-Reply-To: <8738n0ngq3.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 22:18 +0100, Arnaud Ebalard wrote:
> Hi Eric,
> 
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
> > From: Eric Dumazet <edumazet@google.com>
> >
> > After commit c9eeec26e32e ("tcp: TSQ can use a dynamic limit"), several
> > users reported throughput regressions, notably on mvneta and wifi
> > adapters.
> >
> > 802.11 AMPDU requires a fair amount of queueing to be effective.
> >
> > This patch partially reverts the change done in tcp_write_xmit()
> > so that the minimal amount is sysctl_tcp_limit_output_bytes.
> 
> I just tested the fix on current linux tree with the same setup
> on which I observed the regression: it also fixes it on my side
> on my RN102. Thanks for the quick fix, Eric. 
> 

It would be nice you find the 'right value' for the sysctl, to give a
hint to mvneta maintainers ;)

Thanks
