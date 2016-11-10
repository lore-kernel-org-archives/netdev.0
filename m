From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/9] net: add support for IPv6 Segment
 Routing
Date: Thu, 10 Nov 2016 09:45:20 -0500 (EST)
Message-ID: <20161110.094520.452500795334621714.davem@davemloft.net>
References: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be>
        <20161109.204058.1740541278564630528.davem@davemloft.net>
        <58242D90.4020309@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59898 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933541AbcKJOpY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 09:45:24 -0500
In-Reply-To: <58242D90.4020309@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Thu, 10 Nov 2016 09:19:28 +0100

> The Kconfig knob was a response to the concern that direct header
> insertion breaks things. Moreover, if the IETF decides that direct
> header insertion must be explicitely banned in rfc2460bis, then at
> least we do not have a non-RFC compliant behavior by default.

Sysadmins should be allowed to do what they wish.

Most packet filtering and mangling we support is technically not RFC
compliant, so using that as an argument against supporting this or
that facility is kind of silly.
