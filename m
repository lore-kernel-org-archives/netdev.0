From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 8 Aug 2006 14:58:40 +0200
Message-ID: <200608081458.40583.ak@suse.de>
References: <200608080711.06788.ak@suse.de> <20060808.000110.110010976.davem@davemloft.net> <44D88990.3090904@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:2453 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932550AbWHHM6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 08:58:51 -0400
To: Kirill Korotaev <dev@sw.ru>
In-Reply-To: <44D88990.3090904@sw.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 3) should we limit TCP hashe and hashb size the same way?

Yes - or best in fact all hashes handled by alloc_large_system_hash()

-Andi
