From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net] amd-xgbe-phy: Fix initial mode when autoneg is disabled
Date: Tue, 26 May 2015 09:57:33 -0500
Message-ID: <556489DD.3070002@amd.com>
References: <20150526145149.29899.24836.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0118.outbound.protection.outlook.com ([157.56.111.118]:13280
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753666AbbEZO5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2015 10:57:53 -0400
In-Reply-To: <20150526145149.29899.24836.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/26/2015 09:51 AM, Tom Lendacky wrote:
> When the ethtool command is used to set the speed of the device while
> the device is down, the check to set the initial mode may fail when
> the device is brought up, causing failure to bring the device up.
>
> Update the code to set the initial mode based on the desired speed if
> auto-negotiation is disabled.
>
> This patch fixes a bug introduced by:
> d9663c8c2149 ("amd-xgbe-phy: Use phydev advertising field vs supported")
>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>   drivers/net/phy/amd-xgbe-phy.c |   45 +++++++++++++++++++++++++++++++++++++---
>   1 file changed, 42 insertions(+), 3 deletions(-)
>

Hi David,

Just a heads up on this patch. With the removal of this file in net-next
you'll have a conflict when merging into net-next. My updates from the
other day to net-next fix this bug in the new file/location.

Thanks,
Tom
