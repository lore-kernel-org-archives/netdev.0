From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2017-08-21
Date: Mon, 21 Aug 2017 09:30:11 -0700 (PDT)
Message-ID: <20170821.093011.122223256841982342.davem@davemloft.net>
References: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36036 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753536AbdHUQaQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 12:30:16 -0400
In-Reply-To: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 21 Aug 2017 07:49:25 +0200

> 1) Support RX checksum with IPsec crypto offload for esp4/esp6.
>    From Ilan Tayari.
> 
> 2) Fixup IPv6 checksums when doing IPsec crypto offload.
>    From Yossi Kuperman.
> 
> 3) Auto load the xfrom offload modules if a user installs
>    a SA that requests IPsec offload. From Ilan Tayari.
> 
> 4) Clear RX offload informations in xfrm_input to not
>    confuse the TX path with stale offload informations.
>    From Ilan Tayari.
> 
> 5) Allow IPsec GSO for local sockets if the crypto operation
>    will be offloaded.
> 
> 6) Support setting of an output mark to the xfrm_state.
>    This mark can be used to to do the tunnel route lookup.
>    From Lorenzo Colitti.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.
