From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Tue, 27 May 2008 08:19:56 +0200
Message-ID: <483BA80C.4020502@krogh.cc>
References: <20080526.123338.161271834.davem@davemloft.net>	<20080526.123951.260448303.davem@davemloft.net>	<483B239D.4090402@krogh.cc> <20080526.151540.191673092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, matheos.worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:40595 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753749AbYE0GUK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 02:20:10 -0400
In-Reply-To: <20080526.151540.191673092.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jesper Krogh <jesper@krogh.cc>
> Date: Mon, 26 May 2008 22:54:53 +0200
> 
>> Applied and running.. I've now pushed 400GB of data through it trying to
>> get it to hit the bug but it is still running.
>>
>> So without saying that it solved the problem, it definately seems so.
>> 2.6.26-rc4 + above patch.
> 
> Thanks for testing.

Ok. I was too early out.. it ended up in the same situation again.

May 27 08:09:12 hest kernel: [42953871.982072] NETDEV WATCHDOG: eth4: 
transmit timed out
May 27 08:09:17 hest kernel: [42953877.827797] NETDEV WATCHDOG: eth4: 
transmit timed out
May 27 08:09:22 hest kernel: [42953883.958375] NETDEV WATCHDOG: eth4: 
transmit timed out
May 27 08:09:27 hest kernel: [42953890.668401] NETDEV WATCHDOG: eth4: 
transmit timed out


Jesper
-- 
Jesper
