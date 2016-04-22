From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH net-next 04/10] net: hns: add attribute
 reset-field-offset for dsaf node
Date: Fri, 22 Apr 2016 15:44:18 -0500
Message-ID: <20160422204418.GA19071@rob-hp-laptop>
References: <1461309619-167621-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1461309619-167621-5-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	davem@davemloft.net, yankejian@huawei.com,
	huangdaode@hisilicon.com, salil.mehta@huawei.com,
	lipeng321@huawei.com, liguozhu@huawei.com, xieqianqian@huawei.com,
	linuxarm@huawei.com
To: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:34271 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751707AbcDVUoY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 16:44:24 -0400
Content-Disposition: inline
In-Reply-To: <1461309619-167621-5-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2016 at 03:20:13PM +0800, Yisen Zhuang wrote:
> Add the subctrl reset offset for dsaf, this property is used to reset
> xge/ge ports for different dsaf. If this attribute is not present,
> default value 0 will be used.
> 
> Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> ---
>  .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |  2 ++

Please put DT bindings in separate patches and don't modify the same 
binding in a series of patches. You are describing h/w and the h/w is 
not changing.

>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  8 +++++
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  1 +
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 40 +++++++++++++++-------
>  4 files changed, 39 insertions(+), 12 deletions(-)
