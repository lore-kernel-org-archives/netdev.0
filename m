From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] r8169: increase the lifespan of the hardware
 counters dump area.
Date: Mon, 07 Sep 2015 00:05:30 -0700 (PDT)
Message-ID: <20150907.000530.2280325695730676502.davem@davemloft.net>
References: <fb3db9039225ed3a030e779565b8e11f99fc8ae2.1441454454.git.romieu@fr.zoreil.com>
	<20150906103732.GF30539@calimero.vinschen.de>
	<20150906202153.GB19371@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pomidorabelisima@gmail.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429AbbIGHFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 03:05:31 -0400
In-Reply-To: <20150906202153.GB19371@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sun, 6 Sep 2015 22:21:53 +0200

> Corinna Vinschen <vinschen@redhat.com> :
>> On Sep  5 14:18, romieu@fr.zoreil.com wrote:
> [...]
>> > - rtl_reset_counters_cond induced failures in open() are also considered
>> >   fatal: it takes acceptable work to unwind comfortably.
>> 
>> Why?
> 
> 
> Crap, my description does not match the code wrt rtl_reset_counters_cond. :o/
> 
> s/rtl8169_reset_counters/rtl8169_update_counters/g
> 
> The code is right.

Please resubmit with fixed commit log messages, thanks!
