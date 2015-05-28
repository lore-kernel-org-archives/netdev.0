From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Thu, 28 May 2015 08:34:58 -0500
Message-ID: <55671982.6030806@amd.com>
References: <20150528141716.562c15e1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0136.outbound.protection.outlook.com ([65.55.169.136]:2013
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753162AbbE1NfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 09:35:09 -0400
In-Reply-To: <20150528141716.562c15e1@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2015 11:17 PM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/phy/amd-xgbe-phy.c between commit 983942a5eaca
> ("amd-xgbe-phy: Fix initial mode when autoneg is disabled") from Linus'
> tree and commit 7c12aa08779c ("amd-xgbe: Move the PHY support into
> amd-xgbe") from the net-next tree.
>
> I fixed it up (the latter removed the file, so I did that - there may
> be more needed) and can carry the fix as necessary (no action is
> required).

I looked over the tree and it appears that everything is good. Deleting
the file is the correct action and it looks like the necessary changes
to the Makefiles and Kconfigs are present to account for that.

Thanks,
Tom

>
