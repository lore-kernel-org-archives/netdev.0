From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: fix a potential deadlock in tcp_get_info()
Date: Fri, 22 May 2015 11:08:39 -0700
Message-ID: <1432318119.4060.133.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150521.232541.173137306546517818.davem@davemloft.net>
	 <1432266206.4060.119.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432270279.4060.128.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150522.135042.1383929510137041615.davem@redhat.com>
	 <1432317396.4060.130.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432317814.4060.132.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
	ycheng@google.com, mattmathis@google.com, cgallek@google.com,
	kafai@fb.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38297 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757680AbbEVSIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 14:08:42 -0400
Received: by igcau1 with SMTP id au1so38615367igc.1
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 11:08:42 -0700 (PDT)
In-Reply-To: <1432317814.4060.132.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-22 at 11:03 -0700, Eric Dumazet wrote:

> Also I am wondering if not explicitly include <linux/u64_stats_sync.h>
> could break one arch...

Sorry for the false alarm, we should be good because of snmp.h
