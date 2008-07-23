From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 1/2] ipmr: delete redundant variable
Date: Wed, 23 Jul 2008 14:05:39 +0200
Message-ID: <200807231405.39515.netdev@axxeo.de>
References: <48868D54.6050701@cn.fujitsu.com> <200807231003.05848.netdev@axxeo.de> <4886FB56.20905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:49494 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978AbYGWMFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 08:05:49 -0400
In-Reply-To: <4886FB56.20905@cn.fujitsu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wand Chen,

Wang Chen schrieb:
> But "accessing entry of table by index" is always allowed,
> right?
> If the complier makes such pointer which spills a register with
> the multiply/shift, the simple code as following is bug too:
> i = table[100].field;
> But it shouldn't, right :)

I'm NOT telling you, that your transformation is introducing a BUG.
It is semantically perfectly equivalent.

I'm trying to tell you, that it might not led to the same or better 
performance and might thus be not worth it.

But please check the generated assembly yourself on a CISC and RISC
machine to get an idea of the effects. It will be a nice learning 
experience I enjoyed myself already.


Best Regards

Ingo Oeser
