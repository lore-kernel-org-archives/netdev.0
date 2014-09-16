From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v2 4/4] net: sched: cls_fw: add missing tcf_exts_init
 call in fw_change()
Date: Tue, 16 Sep 2014 13:27:35 -0700
Message-ID: <54189D37.4050009@intel.com>
References: <20140916063024.2905.55403.stgit@nitbit.x32>	<20140916063141.2905.59421.stgit@nitbit.x32> <20140916.160020.819013213102038048.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>, john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58112 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753012AbaIPU1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 16:27:48 -0400
In-Reply-To: <20140916.160020.819013213102038048.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2014 01:00 PM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Mon, 15 Sep 2014 23:31:42 -0700
> 
>> When allocating a new structure we also need to call tcf_exts_init
>> to initialize exts.
>>
>> A follow up patch might be in order to remove some of this code
>> and do tcf_exts_assign(). With this we could remove the
>> tcf_exts_init/tcf_exts_change pattern for some of the classifiers.
>> As part of the future tcf_actions RCU series this will need to be
>> done. For now fix the call here.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> Applied.

Great thanks. A couple more patches for cls_u32 coming next. I'm
fairly sure I broke the selector keys usage and the change filter
case is not completely RCU safe yet depending on the netlink
attributes.

Thanks!
John
