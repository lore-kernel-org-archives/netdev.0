From: "Burla, Satananda" <Satananda.Burla@cavium.com>
Subject: Re: [PATCH net-next] liquidio: allocate RX buffers in OOM conditions
 in PF and VF
Date: Thu, 23 Mar 2017 11:47:18 -0700
Message-ID: <20170323184718.h6tb5givw27kvbob@caviumnetworks.com>
References: <20170322183113.GA1035@felix-thinkpad.cavium.com>
 <20170322.193726.2099479598078112953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Manlunas, Felix" <Felix.Manlunas@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0084.outbound.protection.outlook.com ([104.47.38.84]:10916
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934878AbdCWSrp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 14:47:45 -0400
Content-Disposition: inline
In-Reply-To: <20170322.193726.2099479598078112953.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 03/22/2017 19:37, David Miller wrote:
> From: Felix Manlunas <felix.manlunas@cavium.com>
> Date: Wed, 22 Mar 2017 11:31:13 -0700
> 
> > From: Satanand Burla <satananda.burla@cavium.com>
> >
> > Add workqueue that is periodically run to try to allocate RX buffers in OOM
> > conditions in PF and VF.
> >
> > Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> > Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> 
> Applied, but I'm really not so sure you want to poll these queue states
> 4 times a second all the time.
> 
> Why don't you trigger the workqueue when you actually get an allocation
> failure?
That is certainly a better option. We will incorporate that in the
coming series.
-- 
Thanks
Satanand
