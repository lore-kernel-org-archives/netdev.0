From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 4/5] bonding: Added bond_tlb_xmit() for tlb mode.
Date: Wed, 02 Apr 2014 04:02:10 -0700
Message-ID: <1396436530.3989.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396422014-32061-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:59341 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758057AbaDBLCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 07:02:13 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so22997pdi.2
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 04:02:13 -0700 (PDT)
In-Reply-To: <1396422014-32061-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-02 at 00:00 -0700, Mahesh Bandewar wrote:
> Re-organized the xmit function for the lb mode separating tlb xmit
> from the alb mode. This will enable use of the hashing policies
> like 802.3ad mode. Also extended use of xmit-hash-policy to tlb mode.
> 
> Now the tlb-mode defaults to BOND_XMIT_POLICY_LAYER2 if the xmit policy
> module parameter is not set (just like 802.3ad, or Xor mode).
> 
> Change-Id: I140257403d272df75f477b380207338d0f04963e
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v2:
>   Micro optimization - switch statement from ntohs(var) to htons(const) 
> v3:
>   Rebase

As mentioned by Nikolay, no need to init hash_index to 0.

Otherwise :

Acked-by: Eric Dumazet <edumazet@google.com>
