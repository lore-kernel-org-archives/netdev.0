From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] bpf: do not use reciprocal divide
Date: Wed, 15 Jan 2014 17:02:30 -0800 (PST)
Message-ID: <20140115.170230.640619926492650356.davem@davemloft.net>
References: <1389795716.31367.333.camel@edumazet-glaptop2.roam.corp.google.com>
	<1389795926.31367.334.camel@edumazet-glaptop2.roam.corp.google.com>
	<1389797407.31367.340.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	dborkman@redhat.com, darkjames-ws@darkjames.pl, mgherzan@gmail.com,
	rmk+kernel@arm.linux.org.uk, matt@ozlabs.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932AbaAPBCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 20:02:31 -0500
In-Reply-To: <1389797407.31367.340.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Jan 2014 06:50:07 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> At first Jakub Zawadzki noticed that some divisions by reciprocal_divide
> were not correct. (off by one in some cases)
> http://www.wireshark.org/~darkjames/reciprocal-buggy.c
> 
> He could also show this with BPF:
> http://www.wireshark.org/~darkjames/set-and-dump-filter-k-bug.c
> 
> The reciprocal divide in linux kernel is not generic enough,
> lets remove its use in BPF, as it is not worth the pain with
> current cpus.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Jakub Zawadzki <darkjames-ws@darkjames.pl>

Applied and queued up for -stable, thanks Eric.
