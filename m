From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC][PATCH 3/3] IPv4:Check IP_MULTICAST_LOOP option value
Date: Tue, 10 Jun 2008 17:07:34 +0800
Message-ID: <484E4456.4040206@cn.fujitsu.com>
References: <484E3293.8000507@cn.fujitsu.com>	<20080610.171527.86317043.yoshfuji@linux-ipv6.org>	<484E3C0A.1000808@cn.fujitsu.com> <20080610.174202.32087382.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59918 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752518AbYFJJI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 05:08:29 -0400
In-Reply-To: <20080610.174202.32087382.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / 吉藤英明 写道:
> In article <484E3C0A.1000808@cn.fujitsu.com> (at Tue, 10 Jun 2008 16:32:10 +0800), Shan Wei <shanwei@cn.fujitsu.com> says:
> 
>> YOSHIFUJI Hideaki / 吉藤英明 写道:
>>> In article <484E3293.8000507@cn.fujitsu.com> (at Tue, 10 Jun 2008 15:51:47 +0800), Shan Wei <shanwei@cn.fujitsu.com> says:
>>>
>>>> The IP_MULTICAST_LOOP option can only be set with o or 1. When 
>>>> other valuse are set, the kernel should return an error of EINVAL.
>>>>
>>>> In addition, the option should not be uesd by SOCK_STREAM type,
>>>> same as IP_MULTICAST_IF, IP_MULTICAST_TTL.
>>>>   
>>>> But the kernel doesn't check them.
>>> Is there any standard reference about this?
>>>
>> I have not found it.
>> But, the IP_MULTICAST_LOOP option is same as IPV6_MULTICAST_LOOP.
> 
> I disagree.
> We follow what traditional BSDs do, and they do not check if the
> value is 0 or 1 for IP_MULTICAST_LOOP.
> On the other hand, they do for IPV6_MULTICAST_LOOP.
> 
Ok.
no need to check "val".

The option should not be uesd by SOCK_STREAM type.
how do you think of ?
> --yoshfuji
> 
> 
> 


-- 
Regards
単 衛
--------------------------------------------------
Shan Wei
Development Dept.I

Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China
TEL:+86+25-86630566-836
FUJITSU INTERNAL:79955-836
FAX:+86+25-83317685
Mail:shanwei@cn.fujitsu.com
--------------------------------------------------
This communication is for use by the intended recipient(s) only and may contain information that is privileged, confidential and exempt from disclosure under applicable law. If you are not an intended recipient of this communication, you are hereby notified that any dissemination, distribution or copying hereof is strictly prohibited.  If you have received this communication in error, please notify me by reply e-mail, permanently delete this communication from your system, and destroy any hard copies you may have printed.

