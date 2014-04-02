From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 2/5] bonding: Reorg bond_alb_xmit code
Date: Wed, 02 Apr 2014 03:56:53 -0700
Message-ID: <1396436213.3989.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396422010-31981-1-git-send-email-maheshb@google.com>
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
Received: from mail-pa0-f48.google.com ([209.85.220.48]:37180 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758052AbaDBK44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 06:56:56 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so11067pad.21
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 03:56:55 -0700 (PDT)
In-Reply-To: <1396422010-31981-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-02 at 00:00 -0700, Mahesh Bandewar wrote:
> Separating the actual xmit part from the function in a separate
> function that can be used in the tlb_xmit in the next patch. Also
> there is no reason do_tx_balance to be an int so changing it to
> bool type.
> 
> Change-Id: I9c48ff30487810f68587e621a191db616f49bd3b
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
