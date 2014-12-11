From: David Miller <davem@davemloft.net>
Subject: Re: bind() should not return -EADDRINUSE
Date: Thu, 11 Dec 2014 15:25:18 -0500 (EST)
Message-ID: <20141211.152518.1988079810884987306.davem@davemloft.net>
References: <5489FBC8.4070706@ubuntu.com>
	<20141211.151804.2024237965934539073.davem@davemloft.net>
	<5489FD51.3030609@ubuntu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: psusi@ubuntu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56329 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758327AbaLKUZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:25:20 -0500
In-Reply-To: <5489FD51.3030609@ubuntu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phillip Susi <psusi@ubuntu.com>
Date: Thu, 11 Dec 2014 15:23:45 -0500

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On 12/11/2014 3:18 PM, David Miller wrote:
>> From: Phillip Susi <psusi@ubuntu.com> Date: Thu, 11 Dec 2014
>> 15:17:12 -0500
>> 
>>> Says who?
>> 
>> Says multiple decades of precendence.
> 
> "It has always been broken, so it should stay broken" isn't a very
> compelling argument.
> 
> Would it cause programs to break if they get the error at listen()
> time instead of bind() time ( as the man page indicates it can )?  I
> think not.

You will definitely break programs that look for a locally available
port by iterating over bind() calls.

Sorry, this is not changing, no matter how strongly you may wish it
to.
