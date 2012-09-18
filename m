From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net] e1000: Small packets may get corrupted during padding by
 HW
Date: Tue, 18 Sep 2012 07:45:20 +0200
Message-ID: <1347947120.26523.207.camel@edumazet-glaptop>
References: <50578DE4.7080806@intel.com>
	 <1347915723.26523.179.camel@edumazet-glaptop> <5057E3F2.5090504@gmail.com>
	 <20120917.230300.653531213751776624.davem@davemloft.net>
	 <5057EA05.8020005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com,
	tushar.n.dave@intel.com, john.r.fastabend@intel.com,
	mirqus@gmail.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:58497 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047Ab2IRFp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 01:45:26 -0400
Received: by wgbdr13 with SMTP id dr13so6503500wgb.1
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 22:45:25 -0700 (PDT)
In-Reply-To: <5057EA05.8020005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-17 at 20:27 -0700, Alexander Duyck wrote:

> It also just occurred to me that there might be some benefit in cache 
> aligning the max header size.  It seems like doing something like that 
> should reduce the overall memory footprint and would probably improve 
> performance.

Given that most ACK packets are 66 bytes (14 ethernet + 20 IP + 32 TCP),
I am not sure we need to make any tweak on alignment ?
