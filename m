From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/5] bonding: Reorg bond_alb_xmit code
Date: Mon, 31 Mar 2014 08:46:54 -0700
Message-ID: <1396280814.29410.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396070941-17602-1-git-send-email-maheshb@google.com>
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
Received: from mail-pd0-f169.google.com ([209.85.192.169]:39753 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbaCaPrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 11:47:01 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so8197881pdb.28
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 08:47:01 -0700 (PDT)
In-Reply-To: <1396070941-17602-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-28 at 22:29 -0700, Mahesh Bandewar wrote:
> Separating the actual xmit part from the function in a separate
> function that can be used in the tlb_xmit in the next patch. Also
> there is no reason do_tx_balance to be an int so changing it to
> bool type.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
