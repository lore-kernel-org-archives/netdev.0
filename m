From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix Kernel Panic in bonding driver debugfs file:
 rlb_hash_table
Date: Wed, 29 Apr 2015 15:37:47 -0400 (EDT)
Message-ID: <20150429.153747.1168229052245734682.davem@davemloft.net>
References: <E1YnWel-0004R7-1o@bos-lpqrs.kendall.corp.akamai.com>
	<20150429185105.GA545@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vpai@akamai.com, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50489 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbbD2Tht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 15:37:49 -0400
In-Reply-To: <20150429185105.GA545@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Wed, 29 Apr 2015 14:51:07 -0400

> On Wed, Apr 29, 2015 at 02:24:23PM -0400, Pai wrote:
>> This patch fixes a Kernel Panic in bonding driver debugfs file: rlb_hash_table.
>> 
>> $> modprobe bonding mode=6
>> $> cat /sys/kernel/debug/bonding/bond0/rlb_hash_table
>> 
>> This will crash the kernel. The struct alb_bond_info is initialized only when
>> the bonding interface is initialized (ip link set bond0 up) and not at the time
>> it is allocated. If we try to read the table before that, it'll result in a 
>> kernel panic.
> 
> Nice catch!
> 
>> 
>> The patch applies against both net and net-next
>> 
>> Signed-off-by: Vishwanath Pai <vpai@akamai.com>
> 
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

Applied, thanks.
