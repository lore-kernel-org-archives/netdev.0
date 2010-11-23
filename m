From: Li Yewang <lyw@cn.fujitsu.com>
Subject: Re: possible kernel oops from user MSS
Date: Tue, 23 Nov 2010 10:48:46 +0800
Message-ID: <4CEB2B8E.3090904@cn.fujitsu.com>
References: <20101110.124119.102563803.davem@davemloft.net>	<AANLkTin-gXceUQxKvQeP8Nc8oXZDJnyjoFUjYD5x_g_y@mail.gmail.com>	<4CDDC6EE.2010005@mvista.com> <20101112.152607.193708973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mzhang@mvista.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54774 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751016Ab0KWCti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Nov 2010 21:49:38 -0500
In-Reply-To: <20101112.152607.193708973.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



At 2010-11-13 7:26, David Miller wrote:
> From: Min Zhang<mzhang@mvista.com>
> Date: Fri, 12 Nov 2010 14:59:58 -0800
>
>> Regarding commit 7a1abd08d52fdeddb3e9a5a33f2f15cc6a5674d2 ("tcp:
>> Increase TCP_MAXSEG socket option minimum"). What is the reason
>> TCP_MAXSEG minimum be 64? Isn't the exact be 40 which is
>> TCPOLEN_MD5SIG_ALIGNED(20) + TCPOLEN_TSTAMP_ALIGNED(12) + 8?
>>
>> Or is it better to use TCP_MIN_MSS from tcp.h:
>>
>> /* Minimal accepted MSS. It is (60+60+8) - (20+20). */
>> #define TCP_MIN_MSS        88U
>
> I suppose TCP_MIN_MSS would be better to use, I'll make that
> change, thanks.

   David, do you have plan to fix this bug using TCP_MIN_MSS?



