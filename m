From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix copying more bytes than expected in
 sctp_add_bind_addr
Date: Mon, 07 Mar 2016 23:15:13 -0500 (EST)
Message-ID: <20160307.231513.203335424725203680.davem@davemloft.net>
References: <201603080758.oSIf1B2b%fengguang.wu@intel.com>
	<56DE0E4F.3050707@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkp@intel.com, kbuild-all@01.org, netdev@vger.kernel.org,
	dvyukov@google.com, nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org,
	syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
	sasha.levin@oracle.com, edumazet@google.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbcCHEPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 23:15:17 -0500
In-Reply-To: <56DE0E4F.3050707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Mon, 7 Mar 2016 20:27:11 -0300

> Hi,
> 
> Em 07-03-2016 20:17, kbuild test robot escreveu:
>> Hi Marcelo,
>>
>> [auto build test WARNING on net/master]
>>
>> url:
>> https://github.com/0day-ci/linux/commits/Marcelo-Ricardo-Leitner/sctp-fix-copying-more-bytes-than-expected-in-sctp_add_bind_addr/20160308-052009
>>
>>
>> coccinelle warnings: (new ones prefixed by >>)
>>
>>>> net/sctp/bind_addr.c:458:42-48: ERROR: application of sizeof to
>>>> pointer
>>
>> Please review and possibly fold the followup patch.
> 
> Oops, nice catch, thanks.
> 
> I can fold it if Dave prefers, no problem. I'll wait for a
> confirmation.

Please respin your patch with this folded into it, thanks.
