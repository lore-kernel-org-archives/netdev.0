From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/7] net: bcmgenet: simplify bcmgenet_init_dma()
Date: Wed, 25 Mar 2015 15:22:30 -0700
Message-ID: <55133526.6030301@gmail.com>
References: <20150325193511.F0B1E2201FB@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:35405 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbbCYWXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 18:23:13 -0400
Received: by pdbop1 with SMTP id op1so42011296pdb.2
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 15:23:13 -0700 (PDT)
In-Reply-To: <20150325193511.F0B1E2201FB@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/15 12:35, Petri Gynther wrote:
> Do the two kcalloc() calls first, before proceeding into Rx/Tx DMA init.
> Makes the error case handling much simpler.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
