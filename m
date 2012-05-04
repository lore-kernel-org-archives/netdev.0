From: Deng-Cheng Zhu <dczhu@mips.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Fri, 4 May 2012 12:25:33 +0800
Message-ID: <4FA35A3D.8000205@mips.com>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com> <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eric.dumazet@gmail.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns0.mips.com ([12.201.5.70]:55112 "EHLO dns0.mips.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789Ab2EDEZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 00:25:43 -0400
In-Reply-To: <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2012 11:22 AM, Tom Herbert wrote:
>> +struct cpu_flow {
>> +       struct net_device *dev;
>> +       u32 rxhash;
>> +       unsigned long ts;
>> +};
>
> This seems like overkill, we already have the rps_flow_table and this
> used in accelerated RFS so the device can also take advantage of
> steering.

I think the mechanisms of rps_dev_flow_table and cpu_flow (in this
patch) are different: The former works along with rps_sock_flow_table
whose CPU info is based on recvmsg by the application. But for the tests
like what I did, there's no application involved.


Deng-Cheng
