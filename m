From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] bna: Update driver version to 3.0.23.0
Date: Wed, 04 Apr 2012 18:17:18 -0400 (EDT)
Message-ID: <20120404.181718.345441045492163774.davem@davemloft.net>
References: <1332790673-9562-1-git-send-email-huangj@brocade.com>
	<20120404101535.0b739155@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: huangj@brocade.com, netdev@vger.kernel.org,
	adapter_linux_open_src_team@brocade.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753556Ab2DDWSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 18:18:21 -0400
In-Reply-To: <20120404101535.0b739155@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 4 Apr 2012 10:15:35 -0700

> On Mon, 26 Mar 2012 12:37:53 -0700
> Jing Huang <huangj@brocade.com> wrote:
> 
>> This patch set contains fixes in adapter initialization and tx/rx cleanup path.
>> It also include code cleanups by removing and renaming some functions.
>> 
>> The driver version has been updated to 3.0.23.0 to reflect the changes.
>> 
>> Jing Huang (7):
>>   bna: Serialize smem access during adapter initialization
>>   bna: Flash controller ioc pll init fixes
>>   bna: ioc cleanups
>>   bfa: tx rx cleanup fix
>>   bna: Remove tx tasklet
>>   bfa: Function name changes and cleanups
>>   bfa: Update driver version to 3.0.23.0
>> 
>>  drivers/net/ethernet/brocade/bna/bfa_ioc.c      |   61 +++--
>>  drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c   |  142 +++++++----
>>  drivers/net/ethernet/brocade/bna/bfi_reg.h      |    6 +
>>  drivers/net/ethernet/brocade/bna/bnad.c         |  316 +++++++++++------------
>>  drivers/net/ethernet/brocade/bna/bnad.h         |   11 +-
>>  drivers/net/ethernet/brocade/bna/bnad_ethtool.c |    6 +-
>>  6 files changed, 300 insertions(+), 242 deletions(-)
>> 
> 
> When are you going to integrate multi-queue support which is already
> available in your out of tree driver?

I hope your Brocade folks aren't playing the "try to make the out-of-tree
driver more desirable than the in-tree one" game.  I would find that really
irritating.
