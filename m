From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: avoid undefined behavior in do_ip_setsockopt()
Date: Sun, 11 Nov 2012 17:50:56 -0500 (EST)
Message-ID: <20121111.175056.930119228369321440.davem@davemloft.net>
References: <1352668801-14373-1-git-send-email-xi.wang@gmail.com>
	<20121111.170247.780516266044882867.davem@davemloft.net>
	<50A0244F.1070302@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xi.wang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab2KKWve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 17:51:34 -0500
In-Reply-To: <50A0244F.1070302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xi Wang <xi.wang@gmail.com>
Date: Sun, 11 Nov 2012 17:18:55 -0500

> On 11/11/12 5:02 PM, David Miller wrote:
>> 
>> This code is a fast bit test on purpose.  You're making the
>> code slower.
> 
> No, it's the opposite.  All modern compilers optimize switch cases
> into a fast bit test.

Indeed, I even checked sparc64 with gcc-4.6 and it looks good.

Thanks for the clarification, I'll apply this, thanks.
