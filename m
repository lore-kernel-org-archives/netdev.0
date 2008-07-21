From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 20:04:43 +0400
Message-ID: <a4423d670807210904je651e16md5aa61c734de9bdd@mail.gmail.com>
References: <20080720.221106.201055562.davem@davemloft.net>
	 <a4423d670807210248l1e2e6999ha462edc99002f964@mail.gmail.com>
	 <20080721101626.GM10471@solarflare.com>
	 <20080721.083527.199623566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, adobriyan@gmail.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:4995 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbYGUQEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:04:44 -0400
Received: by an-out-0708.google.com with SMTP id d40so376222and.103
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 09:04:43 -0700 (PDT)
In-Reply-To: <20080721.083527.199623566.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/7/21 David Miller <davem@davemloft.net>:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 21 Jul 2008 11:16:27 +0100
>
>> Alexander Beregalov wrote:
>> > Hi David!
>> >
>> > There is another problem on sparc64 and happymeal ethernet card.
>> >
>> > when tring to up interface:
>> >
>> > kernel BUG at net/core/dev.c:1328
>> [...]
>>
>> This is yet another driver calling netif_wake_queue() during dev_open(),
>> when there is no real qdisc present.  (And yes, sfc is another of those
>> drivers - I will post a patch after internal review.)
>
> Yep, what idiot wrote this driver? ;-)
>
> Alexander please try this patch:
It works, thanks.
