From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH,net-next,0/2] Improve code coverage of syzkaller
Date: Tue, 19 Sep 2017 23:08:53 -0700 (PDT)
Message-ID: <20170919.230853.540610280718334640.davem@davemloft.net>
References: <20170919073402.2292-1-peterpenkov96@gmail.com>
        <20170919.160134.534837308168786965.davem@davemloft.net>
        <CA+DcSEjDe=h5Kk2Bg0vCOatQj2Zs8wTAyVH+z5curg4O4c3=Hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peterpenkov96@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35442 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751549AbdITGIz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 02:08:55 -0400
In-Reply-To: <CA+DcSEjDe=h5Kk2Bg0vCOatQj2Zs8wTAyVH+z5curg4O4c3=Hw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petar Penkov <peterpenkov96@gmail.com>
Date: Tue, 19 Sep 2017 21:26:14 -0700

> Furthermore, in a way testing already requires specific kernel
> configuration.  In this particular example, syzkaller prefers
> synchronous operation and therefore needs 4KSTACKS disabled. Other
> features that require rebuilding are KASAN and dbx. From this point
> of view, I still think that having the TUN_NAPI flag has value.

Then I think this path could be enabled/disabled with a runtime flag
just as easily, no?
