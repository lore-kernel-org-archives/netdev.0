From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net v2 0/2] ipv4: fix flowi4_iif for input routing
Date: Wed, 16 Apr 2014 15:06:20 -0400 (EDT)
Message-ID: <20140416.150620.2149050673990844642.davem@davemloft.net>
References: <1397604335-12752-1-git-send-email-xiyou.wangcong@gmail.com>
	<alpine.LFD.2.11.1404160840200.1673@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	ebiederm@xmission.com, cwang@twopensource.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390AbaDPTGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 15:06:22 -0400
In-Reply-To: <alpine.LFD.2.11.1404160840200.1673@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 16 Apr 2014 08:42:31 +0300 (EEST)

> On Tue, 15 Apr 2014, Cong Wang wrote:
> 
>> This patchset fixes ->flowi4_iif for input routing and rp filter,
>> based on suggestion from Julian. See per patch for details.
>> 
>> v1 -> v2:
>> * merge the first two patches into one
>> * fix fib_check_nh() too
>> * add this cover letter
>> 
>> Cc: Eric Biederman <ebiederm@xmission.com>
>> Cc: Julian Anastasov <ja@ssi.bg>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> Signed-off-by: Cong Wang <cwang@twopensource.com>
> 
> 	v2 looks good to me, thanks!
> 
> Reviewed-by: Julian Anastasov <ja@ssi.bg>

Series applied, thanks everyone.
