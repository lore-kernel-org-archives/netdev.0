From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Fri, 13 Feb 2015 10:45:50 +0800
Message-ID: <54DD655E.5020301@windriver.com>
References: <1423719323-4667-1-git-send-email-Yanjun.Zhu@windriver.com>	<1423719323-4667-2-git-send-email-Yanjun.Zhu@windriver.com> <20150212045558.5091262a@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <mst@redhat.com>, <jasowang@redhat.com>,
	<viro@zeniv.linux.org.uk>, <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:32774 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbbBMCpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 21:45:47 -0500
In-Reply-To: <20150212045558.5091262a@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/2015 08:55 PM, Stephen Hemminger wrote:
> On Thu, 12 Feb 2015 13:35:23 +0800
> Zhu Yanjun <Yanjun.Zhu@windriver.com> wrote:
>
>> From: Zhu Yanjun <yanjun.zhu@windriver.com>
>>
>> The default speed of normal nic is 1000M while the default speed
>> of tun is 10M. Now the default speed of tun is changed to 1000M.
>> And there are 3 options: 10M, 100M and 1000M to the speed of tun.
>> The command "ethtool -s tun0 speed 10/100/1000" can configure the
>> speed of tun dynamically.
>>
>> CC: Michael S. Tsirkin <mst@redhat.com>
>> CC: Jason Wang <jasowang@redhat.com>
>> CC: Al Viro <viro@zeniv.linux.org.uk>
>> Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
>> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
> Why limit to 10/100/1000 speed?
> Ethtool speed can be any value
Thanks for your comments.

Yes. But the real physical nic speed often 10M, 100M and 1000M.
This simulates the physical nic.

Zhu Yanjun
>
>>   
>
>
