From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/7] net: bcmgenet: multiple Rx queues support
Date: Wed, 25 Mar 2015 15:32:38 -0700
Message-ID: <55133786.40500@gmail.com>
References: <20150325193509.09C362201FB@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35153 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbbCYWdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 18:33:21 -0400
Received: by pdbop1 with SMTP id op1so42234904pdb.2
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 15:33:20 -0700 (PDT)
In-Reply-To: <20150325193509.09C362201FB@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/15 12:35, Petri Gynther wrote:
> Final patch set to add support for multiple Rx queues:
> 1. remove priv->int0_mask and priv->int1_mask
> 2. modify Tx ring int_enable and int_disable vectors
> 3. simplify bcmgenet_init_dma()
> 4. tweak init_umac()
> 5. rework Tx NAPI code
> 6. rework Rx NAPI code
> 7. add support for multiple Rx queues
> 

Looks very good, thanks for getting these change out! Now I suppose what
we would need is some sort of ethtool rx-nfc API to allow flow
configuration towards particular RX queues?
-- 
Florian
