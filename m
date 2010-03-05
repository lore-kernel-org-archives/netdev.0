From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] ethtool: Add direct access to ops->get_sset_count
Date: Fri, 05 Mar 2010 14:00:39 -0800 (PST)
Message-ID: <20100305.140039.122978684.davem@davemloft.net>
References: <20100304085054.4471.44679.stgit@localhost.localdomain>
	<4B8FB439.8050901@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40385
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755976Ab0CEWAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 17:00:20 -0500
In-Reply-To: <4B8FB439.8050901@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Thu, 04 Mar 2010 08:23:05 -0500

> On 03/04/2010 03:51 AM, Jeff Kirsher wrote:
>> From: Jeff Garzik<jgarzik@redhat.com>
>>
>> This patch is an alternative approach for accessing string
>> counts, vs. the drvinfo indirect approach.  This way the drvinfo
>> space doesn't run out, and we don't break ABI later.
>>
>> Signed-off-by: Jeff Garzik<jgarzik@redhat.com>
>> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>> ---
>>
>>   include/linux/ethtool.h |   17 +++++++++--
>>   net/core/ethtool.c | 72
>>   +++++++++++++++++++++++++++++++++++++++++++++++
>>   2 files changed, 86 insertions(+), 3 deletions(-)
> 
> Both patches look good to me.  There is a cosmetic issue of needing to
> sync up userspace and kernel ethtool.h WRT whitespace and deleted
> constants, but I can do that after DaveM applies this patch.
> 
> Waiting for upstream application, or other objections...

Applied, thanks guys.
