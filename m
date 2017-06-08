From: David Miller <davem@davemloft.net>
Subject: Re: next-20170608 build: 1 failures 4 warnings (next-20170608)
Date: Thu, 08 Jun 2017 10:17:57 -0400 (EDT)
Message-ID: <20170608.101757.1257358800507365931.davem@davemloft.net>
References: <E1dIuCM-0000cQ-QM@optimist>
        <20170608103231.gmqx6qluzcjwzrst@sirena.org.uk>
        <20170608113326.zo3nqwkbx3k42owz@earth>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: broonie@kernel.org, kernel-build-reports@lists.linaro.org,
        linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
        netdev@vger.kernel.org
To: sre@kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170608113326.zo3nqwkbx3k42owz@earth>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Reichel <sre@kernel.org>
Date: Thu, 8 Jun 2017 13:33:26 +0200

> Hi,
> 
> On Thu, Jun 08, 2017 at 11:32:31AM +0100, Mark Brown wrote:
>> On Thu, Jun 08, 2017 at 10:57:50AM +0100, Build bot for Mark Brown wrote:
>> 
>> Today's -next fails to build an ARM allmodconfig due to:
>> 
>> > 	arm-allmodconfig
>> > ../drivers/hsi/clients/ssi_protocol.c:1069:5: error: 'struct net_device' has no member named 'destructor'
>> 
>> due to cf124db566e6 (net: Fix inconsistent teardown and release of
>> private netdev state.) which missed this instance, presumably due to a
>> combination of it not being in one of the normal networking driver
>> directories and only being buildable on ARM.
> 
> I assume, that this will be fixed via the net tree.
> If you Cc me on updated/new patch I will provide Acked-by.

It is fixed in the 'net' tree, don't worry about it :-)
