From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: If bridge have no sub-interfaces, it's status may be still with
 'RUNNING'
Date: Fri, 13 Feb 2015 18:00:23 +0800
Message-ID: <54DDCB37.60603@windriver.com>
References: <54DDCA99.4040401@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>,
	"stephen@networkplumber.org >> Stephen Hemminger"
	<stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:38792 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbbBMKAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 05:00:20 -0500
In-Reply-To: <54DDCA99.4040401@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the maintainer of bridge.

Any reply is appreciated.

Zhu Yanjun

On 02/13/2015 05:57 PM, yzhu1 wrote:
> Hi, all
>
> I made this test on ubuntu 14.04 with kernel 3,19-rc7:
>
> 1. brctl addbr br0
>
> 2. ifconfig br0 up
>
> 3. ifconfig br0 (br0's status is with 'RUNNING')
>
> 4. brctl addif br0 eth0
>
> 5. brctl delif br0 eth0
>
> 6. ifconfig br0 (br0's status is without 'RUNNING')
>
> When there is no sub-interface, the flag "RUNNING" is missing after 
> the last sub-interface is removed.
>
> As such, should we keep "RUNNING" flag after the last sub-interface is 
> removed?
>
> Thanks a lot.
> Zhu Yanjun
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
