From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: unix socket code abuses csum_partial
Date: Tue, 04 Mar 2014 13:55:09 -0800
Message-ID: <1393970109.26794.129.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140304210104.42ef3dd8@kryten>
	 <20140304.134141.1732220919806520941.davem@davemloft.net>
	 <1393959053.26794.126.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140304.162329.504474868666088316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, edumazet@google.com, gustavold@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:39295 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299AbaCDVzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 16:55:13 -0500
Received: by mail-yh0-f42.google.com with SMTP id a41so169838yho.1
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 13:55:12 -0800 (PST)
In-Reply-To: <20140304.162329.504474868666088316.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-04 at 16:23 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>

> > Or simply use full_name_hash()
> 
> I would prefer not, because this would be a performance regression
> on platforms other than x86 and ARM, because only they implement
> the optimized load_unaligned_zeropad().
> 
> Other architectures would end up with a byte-by-byte hash computation.

Oh right, I missed this was fast only on x86 and ARM.

Sound like a project for arches maintainers then ;)
