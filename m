From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6 addrconf: enable use of proc_dointvec_minmax in
 addrconf_sysctl
Date: Wed, 28 Sep 2016 11:21:53 -0400 (EDT)
Message-ID: <20160928.112153.1904927986517775222.davem@davemloft.net>
References: <20160928.074901.901607987499248966.davem@davemloft.net>
        <20160928.075204.140017839812712683.davem@davemloft.net>
        <CAHo-Oowk-YN2bHkWWKe_yAWsXQtybu3CZ+beXTiAO9914vouyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: hannes@stressinduktion.org, ek@google.com, lorenzo@google.com,
        netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36500 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932532AbcI1PV5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 11:21:57 -0400
In-Reply-To: <CAHo-Oowk-YN2bHkWWKe_yAWsXQtybu3CZ+beXTiAO9914vouyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej ¯enczykowski <zenczykowski@gmail.com>
Date: Wed, 28 Sep 2016 22:23:10 +0900

> Anyway, enough, I give up, this isn't worth my time, and it's also not
> worth your time.
> I removed the dependency from the other patches and squashed them all into
> 1 to make reviewing easier.

Splitting things up is sometimes warranted, but you have to keep
together the things that strongly need each other.

And new facilities require examples of their use.  They really do.

I simply can't look at your patch and empty commit message and figure
out why you needed to do what you were doing.

Any developer should be able to look at a patch being proposed and be
able to understand it standing upon on it's own.  This means they
shouldn't have to know what happened in this discussion thread or that
one in order to evaluate and audit the patch properly.
