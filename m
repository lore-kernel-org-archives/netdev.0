From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 4/4] net/mlx4_en: Split SW RX dropped counter per RX
 ring
Date: Wed, 20 Apr 2016 11:05:10 -0700
Message-ID: <5717C4D6.4020704@gmail.com>
References: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
 <1461157278-18528-5-git-send-email-ogerlitz@mellanox.com>
 <1461164209.10638.262.camel@edumazet-glaptop3.roam.corp.google.com>
 <571799A3.402@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35079 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219AbcDTSHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 14:07:22 -0400
Received: by mail-pf0-f172.google.com with SMTP id n1so20710139pfn.2
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 11:07:21 -0700 (PDT)
In-Reply-To: <571799A3.402@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/04/16 08:00, Or Gerlitz wrote:
> On 4/20/2016 5:56 PM, Eric Dumazet wrote:
>>> >Fixes: a3333b35da16 ('net/mlx4_en: Moderate ethtool callback to
>>> [...] ')
>>> >Signed-off-by: Eran Ben Elisha<eranbe@mellanox.com>
>>> >Reported-by: Brenden Blanco<bblanco@plumgrid.com>
>>> >Signed-off-by: Saeed Mahameed<saeedm@mellanox.com>
>>> >Signed-off-by: Or Gerlitz<ogerlitz@mellanox.com>
>>> >---
>> Reported-by: Eric Dumazet<edumazet@google.com>
>>
>> (http://www.spinics.net/lists/netdev/msg371318.html  )
> 
> Hi Eric,
> 
> Just to be sure, you'd like me to re-spin this and fix the reporter name?

There is no need for that, patchwork amends Reported-by (and a bunch of
other tags) automatically when somebody replies to the message, see the
resulting mbox for this patch:

http://patchwork.ozlabs.org/patch/612664/mbox/
-- 
Florian
