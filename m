From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Sat, 13 Apr 2013 18:47:27 -0400 (EDT)
Message-ID: <20130413.184727.1419644906707693070.davem@davemloft.net>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com>
	<1365879412-9541-1-git-send-email-willemb@google.com>
	<5169D9C8.8010504@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, paul.chavent@onera.fr,
	richardcochran@gmail.com, edumazet@google.com,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831Ab3DMWr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 18:47:29 -0400
In-Reply-To: <5169D9C8.8010504@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sun, 14 Apr 2013 00:18:48 +0200

>> +		flush_dcache_page(pgv_to_page(&h1->tp_sec));
>> +		flush_dcache_page(pgv_to_page(&h1->tp_usec));
> 
> Hmm, not sure, but could we also flush the dcache only once?

Indeed, I truly hope that headers never straddle pages.
