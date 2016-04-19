From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 2/8] sfc: batch up RX delivery on EF10
Date: Tue, 19 Apr 2016 11:02:06 -0700
Message-ID: <1461088926.10638.223.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5716338E.4050003@solarflare.com>
	 <57163404.2000507@solarflare.com>
	 <1461077257.10638.185.camel@edumazet-glaptop3.roam.corp.google.com>
	 <57165E73.60402@solarflare.com>
	 <1461086440.10638.208.camel@edumazet-glaptop3.roam.corp.google.com>
	 <57166E17.6030002@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36775 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651AbcDSSCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 14:02:07 -0400
Received: by mail-pa0-f48.google.com with SMTP id er2so8866689pad.3
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 11:02:06 -0700 (PDT)
In-Reply-To: <57166E17.6030002@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-19 at 18:42 +0100, Edward Cree wrote:

> Well, I don't know how to achieve that, but it sounds like you do, so why
> not go ahead and show us ;)
> If you submitted a patch series to make UDP twice as fast, I think people
> would "really care" about an improvement of that magnitude.

Yes I definitely can do that, but Google uses SO_REUSEPORT so we do not
care at all consuming more cycles, if we still can absorb the load.

Just try it, and you'll reach 10 Mpps just fine.
