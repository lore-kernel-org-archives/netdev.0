From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Tue, 19 Nov 2013 16:08:49 -0800
Message-ID: <1384906129.8604.132.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu>
	 <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
	 <20131117141940.GA18569@1wt.eu>
	 <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87li0kkhzx.fsf@natisbad.org>
	 <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131119174323.GH913@1wt.eu>
	 <1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, netdev@vger.kernel.org,
	edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:62406 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384Ab3KTAIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 19:08:53 -0500
Received: by mail-yh0-f47.google.com with SMTP id 29so1683531yhl.20
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 16:08:52 -0800 (PST)
In-Reply-To: <874n780wzc.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-20 at 00:53 +0100, Arnaud Ebalard wrote:

> Anyway, I think if the thread keeps going on improving mvneta, I'll do
> all additional tests from RAM and will stop polluting netdev w/ possible
> sata/disk/fs issues.

;)

Alternative would be to use netperf or iperf to not use disk at all
and focus on TCP/network issues only.

Thanks !
