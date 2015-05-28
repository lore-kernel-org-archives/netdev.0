From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Thu, 28 May 2015 08:55:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB4175B@AcuExch.aculab.com>
References: <1432671437-19140-1-git-send-email-ido@wizery.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB40A1A@AcuExch.aculab.com>
 <1432734077.4060.382.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150527144029.GA558@WorkStation.home>
 <1432738585.4060.392.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150527152337.GB558@WorkStation.home>
 <1432743816.4060.404.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150527165403.GC558@WorkStation.home>
 <1432747456.4060.409.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150527191526.GA17823@WorkStation.home>
 <20150528043729.GA32339@WorkStation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Nandita Dukkipati" <nanditad@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ido Yariv <idox.yariv@intel.com>
To: 'Ido Yariv' <ido@wizery.com>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:51153 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbbE1I5Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 04:57:25 -0400
In-Reply-To: <20150528043729.GA32339@WorkStation.home>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Yariv
> Sent: 28 May 2015 05:37
...
> +/* Convert msecs to jiffies, ensuring that the return value is at least 2
> + * jiffies.
> + * This can be used when setting tick-based timers to guarantee that they won't
> + * expire right away.
> + */
> +static inline unsigned long tcp_safe_msecs_to_jiffies(const unsigned int m)

I don't like using 'safe' in function names, being 'safe; depends on what
the caller wants.
Maybe tcp_msecs_to_jiffies_min_2() would be better.

	David
