From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: Re: [PATCH 1/1] net/ipv6: add sysctl option accept_ra_min_hop_limit
Date: Wed, 6 Jan 2016 11:23:09 +0900
Message-ID: <568C7A8D.1060000@jp.fujitsu.com>
References: <1451896664-14271-1-git-send-email-machida.yuki@jp.fujitsu.com>
 <568B9836.1000202@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: Hangbin Liu <liuhangbin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"YOSHIFUJI Hideaki (USAGI Project)" <yoshfuji@linux-ipv6.org>,
	Yuki Machida <machida.yuki@jp.fujitsu.com>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm02.jp.fujitsu.com ([202.219.69.169]:15622 "EHLO
	mgwkm02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbcAFCda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 21:33:30 -0500
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 68E03AC02D1
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 11:23:09 +0900 (JST)
In-Reply-To: <568B9836.1000202@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Yoshifuji-san.

Thanks for your kindly check.
I will correct it in Patch v2.

Best Regards,
Yuki Machida

On 2016年01月05日 19:17, YOSHIFUJI Hideaki wrote:
> Hi, Machida-san.
> 
> Yuki Machida wrote:
>> Please apply the following patch to v4.1.x.
>>
>> By ommit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface")
> 
> s/ommit/commit/
> 
> Futher comment below.
> 
> :
>> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
>> Acked-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>   Documentation/networking/ip-sysctl.txt |  8 ++++++++
>>   include/linux/ipv6.h                   |  1 +
>>   include/uapi/linux/ipv6.h              |  1 +
>>   net/ipv6/addrconf.c                    | 10 ++++++++++
>>   net/ipv6/ndisc.c                       | 16 +++++++---------
>>   5 files changed, 27 insertions(+), 9 deletions(-)
>>
>> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
>> index 071fb18..07fad3d 100644
> :
>> --- a/include/uapi/linux/ipv6.h
>> +++ b/include/uapi/linux/ipv6.h
>> @@ -171,6 +171,7 @@ enum {
>>   	DEVCONF_USE_OPTIMISTIC,
>>   	DEVCONF_ACCEPT_RA_MTU,
>>   	DEVCONF_STABLE_SECRET,
> 
> You have to add a hole for DEVCONF_USE_OIF_ADDRS_ONLY.
> 
> --yoshfuji
> 
>> +	DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
>>   	DEVCONF_MAX
>>   };
>>   
> 
