From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tun: remove useless codes in tun_chr_aio_read()
 and tun_recvmsg()
Date: Tue, 10 Dec 2013 14:00:36 -0500 (EST)
Message-ID: <20131210.140036.1328560146971385473.davem@davemloft.net>
References: <1386363300-19040-2-git-send-email-zwu.kernel@gmail.com>
	<20131209.203646.425478975392590777.davem@davemloft.net>
	<52A74CD1.808@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zwu.kernel@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, wuzhy@linux.vnet.ibm.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51279 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab3LJTAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 14:00:40 -0500
In-Reply-To: <52A74CD1.808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Tue, 10 Dec 2013 12:18:09 -0500

> On 12/09/2013 08:36 PM, David Miller wrote:
>> From: Zhi Yong Wu <zwu.kernel@gmail.com>
>> Date: Sat,  7 Dec 2013 04:55:00 +0800
>> 
>>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>>
>>> By checking related codes, it is impossible that ret > len or total_len,
>>> so we should remove some useless codes in both above functions.
>>>
>>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>> 
>> Applied.
> 
> Wait a sec.  We want to be able to return a value bigger then len
> to trigger a MSG_TRUNC.  Jason has patches for to fix this.  If you
> apply this, we'll have to re-introduce this code back in.
> 
> Same goes for patch 1/2.

That's fine, right now the code makes no sense as the condition can
never be triggered so there is no harm removing the illogical code
meanwhile.
