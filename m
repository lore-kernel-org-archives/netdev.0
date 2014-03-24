From: wangyufen <wangyufen@huawei.com>
Subject: Re: [PATCH net-next 2/2] net: tcp_ipv6 policy route issue
Date: Mon, 24 Mar 2014 09:15:51 +0800
Message-ID: <532F8747.4050005@huawei.com>
References: <1395546460-8332-1-git-send-email-wangyufen@huawei.com> <1395546460-8332-2-git-send-email-wangyufen@huawei.com> <20140323.004535.1122322865637645199.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:48787 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbaCXBQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 21:16:20 -0400
In-Reply-To: <20140323.004535.1122322865637645199.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/23 12:45, David Miller wrote:
> From: Wangyufen <wangyufen@huawei.com>
> Date: Sun, 23 Mar 2014 11:47:40 +0800
> 
>> From: Wang Yufen <wangyufen@huawei.com>
>>
>>     The issue raises when adding policy route,specify a particular
>>     NIC as oif. The policy route did not take effect.
>>     The reason is that fl6.oif is not set and route map failed.
>>
>>     From the tcp_v6_send_response function:
>>     If the binding address is linklocal, fl6.oif is set,
>>     but not for global address.
> 
> Please do not indent your commit log message text like this,
> make the text start at the first column just like your Signoff
> and From: line.
> 
> Please place a space after punction such as "," characters.
> 
>> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
> 
> 
Thanks, I'll send v2 later.
