From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] l2tp: device MTU setup, tunnel socket needs a
 lock
Date: Mon, 17 Apr 2017 13:02:19 -0400 (EDT)
Message-ID: <20170417.130219.1164262427000511625.davem@davemloft.net>
References: <alpine.DEB.2.11.1704121825410.1923@nelson51.eng.vyatta.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kleptog@svana.org, jchapman@katalix.com,
        nprachan@brocade.com, rshearma@brocade.com,
        stephen@networkplumber.org, sdietric@brocade.com,
        ciwillia@brocade.com, lboccass@brocade.com, dfawcus@brocade.com,
        bhong@brocade.com, jblunck@brocade.com, g.nault@alphalink.fr,
        linux-kernel@vger.kernel.org
To: parameswaran.r7@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752389AbdDQRC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:02:29 -0400
In-Reply-To: <alpine.DEB.2.11.1704121825410.1923@nelson51.eng.vyatta.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Date: Wed, 12 Apr 2017 18:31:04 -0700 (PDT)

> 
> The MTU overhead calculation in L2TP device set-up
> merged via commit b784e7ebfce8cfb16c6f95e14e8532d0768ab7ff
> needs to be adjusted to lock the tunnel socket while
> referencing the sub-data structures to derive the
> socket's IP overhead.
> 
> Reported-by: Guillaume Nault <g.nault@alphalink.fr>
> Tested-by: Guillaume Nault <g.nault@alphalink.fr>
> Signed-off-by: R. Parameswaran <rparames@brocade.com>

Applied, thanks.
