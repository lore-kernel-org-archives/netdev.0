From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/5] ulp: Generalize ULP infrastructure
Date: Tue, 08 Aug 2017 18:07:23 -0700 (PDT)
Message-ID: <20170808.180723.1988658908878753961.davem@davemloft.net>
References: <598A1146.9090205@gmail.com>
        <CAPDqMer5fh9xKTcA5fuycoOcHaOcFVRnnfEBJYj_Jv1S=R0-xQ@mail.gmail.com>
        <6bee85e2-5fb3-135a-ad7c-ae4a350f7148@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@quantonium.net, john.fastabend@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, rohit@quantonium.net, davejwatson@fb.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58254 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752319AbdHIBHY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 21:07:24 -0400
In-Reply-To: <6bee85e2-5fb3-135a-ad7c-ae4a350f7148@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 8 Aug 2017 21:23:03 +0100

> In any case, if you go with the enum approach and later it _does_ prove
>  necessary to have more flexibility, you can have enum values dynamically
>  assigned (like genetlink manages to do); and programs using the existing
>  fixed IDs will continue to work.

Indeed:

> It's much harder to go the other way...

^^^^ THIS!
