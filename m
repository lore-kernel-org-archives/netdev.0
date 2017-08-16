From: David Miller <davem@davemloft.net>
Subject: Re: Regression: Bug 196547 - Since 4.12 - bonding module not
 working with wireless drivers
Date: Wed, 16 Aug 2017 14:31:16 -0700 (PDT)
Message-ID: <20170816.143116.1172751167543812070.davem@davemloft.net>
References: <CADps9UCgqeUh41iHxCM+CTJh=Tffn-tiSYL2Q+NBb_8EppqRMA@mail.gmail.com>
        <2b6fd91a-f7cd-c2bf-6394-060d9b1f5d23@nurealm.net>
        <1502918561.30484.1.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: james@nurealm.net, futur.andy@googlemail.com, kvalo@codeaurora.org,
        arend.vanspriel@broadcom.com, maheshb@google.com,
        andy@greyhouse.net, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, greearb@candelatech.com
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38768 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752298AbdHPVbR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 17:31:17 -0400
In-Reply-To: <1502918561.30484.1.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Wed, 16 Aug 2017 16:22:41 -0500

> My biggest suggestion is that perhaps bonding should grow hysteresis
> for link speeds. Since WiFi can change speed every packet, you probably
> don't want the bond characteristics changing every couple seconds just
> in case your WiFi link is jumping around.  Ethernet won't bounce around
> that much, so the hysteresis would have no effect there.  Or, if people
> are concerned about response time to speed changes on ethernet (where
> you probably do want an instant switch-over) some new flag to indicate
> that certain devices don't have stable speeds over time.

Or just report the average of the range the wireless link can hit, and
be done with it.

I think you guys are overcomplicating things.
