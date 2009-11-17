From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 v2] KS8695: fix ks8695_rx() unreasonable action.
Date: Mon, 16 Nov 2009 23:52:00 -0800 (PST)
Message-ID: <20091116.235200.210617103.davem@davemloft.net>
References: <1258383490-13341-1-git-send-email-zeal>
	<4b016886.16115e0a.355d.ffffca52@mx.google.com>
	<1258046194.1931.18.camel@myhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zealcook@gmail.com, netdev@vger.kernel.org, ben@simtec.co.uk
To: figo1802@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754335AbZKQHvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 02:51:44 -0500
In-Reply-To: <1258046194.1931.18.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Figo.zhang" <figo1802@gmail.com>
Date: Fri, 13 Nov 2009 01:16:34 +0800

> On Mon, 2009-11-16 at 22:58 +0800, zeal wrote:
>> From: zeal <zealcook@gmail.com>
>> 
>> ks8695_rx() will call refill_buffers() for every incoming packet.
>> Its not necessary. We just need do it after finishing receiving thing.
>> And the 'RX dma engine' is in the same situation.
>> This blocks our user space application. The following patch may fix it.
>> 
> 
> yes, it is right.
> 
> Best,
> Figo.zhang
> 
>> Signed-off-by: zeal <zealcook@gmail.com>

Patch applied.
