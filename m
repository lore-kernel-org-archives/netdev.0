From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH,net-next,0/2] Improve code coverage of syzkaller
Date: Wed, 20 Sep 2017 09:36:46 -0700 (PDT)
Message-ID: <20170920.093646.2147747625061858821.davem@davemloft.net>
References: <CA+DcSEjDe=h5Kk2Bg0vCOatQj2Zs8wTAyVH+z5curg4O4c3=Hw@mail.gmail.com>
        <20170919.230853.540610280718334640.davem@davemloft.net>
        <CAF=yD-J_qL=hkgnbgPmHW3o_iC6WKmqFUZmmzQKs-+AUhEWY-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterpenkov96@gmail.com, netdev@vger.kernel.org
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56132 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdITQgr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 12:36:47 -0400
In-Reply-To: <CAF=yD-J_qL=hkgnbgPmHW3o_iC6WKmqFUZmmzQKs-+AUhEWY-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed, 20 Sep 2017 11:38:45 -0400

> I think that the compile time option was chosen because of the ns_capable
> check, so that with user namespaces unprivileged processes can control this
> path. Perhaps we can require capable() only to set IFF_NAPI_FRAGS.
> 
> Then we can convert the napi_gro_receive path to be conditional on a new
> IFF_NAPI flag instead of this compile time option.

That works for me.
