From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: optimize xmit path
Date: Tue, 30 Sep 2014 05:11:53 -0700
Message-ID: <1412079113.30721.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
		 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
		 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
		 <1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>
		 <CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>
		 <1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>
		 <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411964353.30721.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <542A9BAC.6010208@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:64624 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbaI3ML4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 08:11:56 -0400
Received: by mail-pa0-f48.google.com with SMTP id eu11so1714613pac.35
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 05:11:56 -0700 (PDT)
In-Reply-To: <542A9BAC.6010208@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 15:01 +0300, Amir Vadai wrote:

> Hi,
> 
> Thanks for the great work Eric.
> 
> I'm working to split the patch and pass it through some regression tests
> and performance benchmarking.
> Will send the split patch-set in few days.

This looks great, thanks Amir.
