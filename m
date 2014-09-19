From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: set gso_segs in LRO mode
Date: Thu, 18 Sep 2014 22:09:33 -0700
Message-ID: <1411103373.7106.296.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411073324.7106.294.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <ariel.elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:37041 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbaISFJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 01:09:35 -0400
Received: by mail-pa0-f54.google.com with SMTP id lj1so3105270pab.41
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 22:09:35 -0700 (PDT)
In-Reply-To: <1411073324.7106.294.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-18 at 13:48 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> In commits cbf1de72324a8 ("bnx2x: fix GRO parameters"), and
> ab5777d748302 ("bnx2x: Get gso_segs from FW")
> special care was taken for GRO mode.
> 
> We can also get proper gso_segs for LRO mode.
> 
> This helps to get proper values for these SNMP counters, which should
> count number of segments. This also helps qdisc_pkt_len_init() to better
> track packet sizes when ingress qdisc is in place.
> 
> IpExtInNoECTPkts                63458
> IpExtInECT0Pkts                 8772480
> IpExtInCEPkts                   1390713
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Please disregard this patch. Its not needed, as bnx2x_gro_receive() is
called even in LRO mode...
