From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] ipmr: delete redundant variable
Date: Wed, 23 Jul 2008 23:16:24 +0800
Message-ID: <48874B48.8060001@cn.fujitsu.com>
References: <48868D54.6050701@cn.fujitsu.com> <200807231003.05848.netdev@axxeo.de> <4886FB56.20905@cn.fujitsu.com> <200807231405.39515.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58426 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750971AbYGWPSH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 11:18:07 -0400
In-Reply-To: <200807231405.39515.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Oeser said the following on 2008-7-23 20:05:
> Hi Wand Chen,
> 
> Wang Chen schrieb:
>> But "accessing entry of table by index" is always allowed,
>> right?
>> If the complier makes such pointer which spills a register with
>> the multiply/shift, the simple code as following is bug too:
>> i = table[100].field;
>> But it shouldn't, right :)
> 
> I'm NOT telling you, that your transformation is introducing a BUG.
> It is semantically perfectly equivalent.
> 
> I'm trying to tell you, that it might not led to the same or better 
> performance and might thus be not worth it.
> 

Agree. I also think the accessing by index might lead to worse performance.
But in this code, we don't care performance, since it only be called when
device is unregistered. :)

> But please check the generated assembly yourself on a CISC and RISC
> machine to get an idea of the effects. It will be a nice learning 
> experience I enjoyed myself already.
> 

Sure. I am doing it.

