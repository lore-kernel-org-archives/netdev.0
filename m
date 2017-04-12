From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: Re: [PATCH net-next] net: dwc-xlgmac: add the initial ethtool support
Date: Wed, 12 Apr 2017 13:08:08 +0800
Message-ID: <2a437683-a422-4db0-8583-7b002e74e71d@synopsys.com>
References: <f1495b53a7ddd2c4bbccdd4b629f57035139c7b6.1491898365.git.jiedeng@synopsys.com>
 <20170411.104749.1916353709565387637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Jie.Deng1@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:60467 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750899AbdDLFKU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 01:10:20 -0400
In-Reply-To: <20170411.104749.1916353709565387637.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/4/11 22:47, David Miller wrote:

> From: Jie Deng <Jie.Deng1@synopsys.com>
> Date: Tue, 11 Apr 2017 16:14:04 +0800
>
>> It is necessary to provide ethtool support for displaying and
>> modifying parameters of dwc-xlgmac.
>>
>> Signed-off-by: Jie Deng <jiedeng@synopsys.com>
> I don't see why you cannot allow the statistics to be obtained when
> the device is not running.  Similarly for other ethtool calls that
> just fetch information stored in the software state of the driver.
>
> I think your ->begin() method is way too restrictive.
Yeah, begin() seems unreasonable here. I will remove it.
