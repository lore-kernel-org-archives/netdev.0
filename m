From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: If bridge have no sub-interfaces, it's status may be still with
 'RUNNING'
Date: Tue, 10 Mar 2015 14:07:30 +0800
Message-ID: <54FE8A22.4020608@windriver.com>
References: <54DDCA99.4040401@windriver.com> <20150213133056.3944c13e@uryu.home.lan> <54E17853.8070106@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>,
	"dsahern@gmail.com >> David Ahern" <dsahern@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58535 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbbCJGIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 02:08:40 -0400
In-Reply-To: <54E17853.8070106@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Stephen && David

Any update ?

Best Regards!
Zhu Yanjun
On 02/16/2015 12:55 PM, yzhu1 wrote:
> Hi, Stephen
>
> Follow your advice, I made a new patch. This patch will turn off
> carrier when a new bridge interface is created. Please comment on it.
>
> Thanks a lot.
> Zhu Yanjun
> On 02/14/2015 02:30 AM, Stephen Hemminger wrote:
>> On Fri, 13 Feb 2015 17:57:45 +0800
>> yzhu1 <Yanjun.Zhu@windriver.com> wrote:
>>
>>> Hi, all
>>>
>>> I made this test on ubuntu 14.04 with kernel 3,19-rc7:
>>>
>>> 1. brctl addbr br0
>>>
>>> 2. ifconfig br0 up
>>>
>>> 3. ifconfig br0 (br0's status is with 'RUNNING')
>>>
>>> 4. brctl addif br0 eth0
>>>
>>> 5. brctl delif br0 eth0
>>>
>>> 6. ifconfig br0 (br0's status is without 'RUNNING')
>>>
>>> When there is no sub-interface, the flag "RUNNING" is missing after the
>>> last sub-interface is removed.
>>>
>>> As such, should we keep "RUNNING" flag after the last sub-interface is
>>> removed?
>> This is intentional. If there are no active ports in bridge, then
>> we want to tell applications that packets will go nowhere.
>>
>>
>
