From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: unify the pcpu_tstats and br_cpu_netstats
Date: Fri, 03 Jan 2014 19:46:53 -0500 (EST)
Message-ID: <20140103.194653.2008101352223130447.davem@davemloft.net>
References: <slrnlccgj7.3uh.xiyou.wangcong@linux-6brj.site>
	<20140103.193253.2226162174184357030.davem@davemloft.net>
	<CAM_iQpUNgwUioWxDXe2DAhVFo0gvPudM1-_CXiNG2rZCnzLTag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbaADAqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:46:55 -0500
In-Reply-To: <CAM_iQpUNgwUioWxDXe2DAhVFo0gvPudM1-_CXiNG2rZCnzLTag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 3 Jan 2014 16:43:37 -0800

> On Fri, Jan 3, 2014 at 4:32 PM, David Miller <davem@davemloft.net> wrote:
>> From: Cong Wang <xiyou.wangcong@gmail.com>
>> Date: Fri, 3 Jan 2014 04:53:47 +0000 (UTC)
>>
>> This also means that since they are now an encapsulation thing we
>> should rename them to pcpu_encap_stats or similar, thanks.
> 
> Not sure "encap" makes sense for bridge too.

Good point, perhaps the common thing is that they are all software
devices in one sense or another.  So "pcpu_sw_netstats".
