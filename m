From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [Bridge] [PATCH net] bridge: Prevent insertion of FDB entry
 with disallowed vlan
Date: Wed, 28 May 2014 23:32:50 +0900
Message-ID: <1401287570.1873.4.camel@localhost.localdomain>
References: <1401084953-10135-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <5385EC5D.40106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:51956 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801AbaE1Oc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 10:32:56 -0400
Received: by mail-pa0-f44.google.com with SMTP id ld10so11095246pab.31
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 07:32:56 -0700 (PDT)
In-Reply-To: <5385EC5D.40106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-28 at 10:02 -0400, Vlad Yasevich wrote:
...
> 
> This is very similar to br_allow_ingress(), so may be you can
> re-factor so that we only have 1 such function...

Yes.. indeed, this looks redundant.
What bothered me is br_allowed_ingress() modifies or drops frames but
I'm not expecting it here.
Maybe we can hand a hint to br_allowed_ingress so that it doesn't modify
the skb?

Thanks,
Toshiaki Makita
