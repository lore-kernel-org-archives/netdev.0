From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH V2 00/22] net-next: mediatek: various fixes and IRQ
 grouping
Date: Mon, 9 May 2016 18:25:04 +0200
Message-ID: <89076f3c-3be2-c038-6c25-a1c95145e3eb@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
 <20160509.120227.2024353376219563839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	nbd@nbd.name
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:40403 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbcEIQZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 12:25:14 -0400
In-Reply-To: <20160509.120227.2024353376219563839.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/05/2016 18:02, David Miller wrote:
> From: John Crispin <john@phrozen.org>
> Date: Mon,  9 May 2016 12:03:52 +0200
> 
>> This series introduces a number of fixes that we stumbled across while
>> doing more performance testing and code level reviewing. Additionally
>> it improves the PHY setup code adding support for fixed phys, asymmetric
>> flow control and gigabit feature advertisement. Next the series adds a
>> support for IRQ grouping, allowing use to separate the IRQs onto more than
>> one core using irq affinity. The last two patches wrap up the series by
>> updating my email address.
> 
> This is too many patches to submit as a unit at one time.  Plus
> this patch series contains lots of unrelated changes.
> 
> Split this up into logical units of related changes, and then submit
> each smaller series one at a time, waiting each time for the current
> series to be accepted before submitting the next one.
> 
> This is what I was trying to encourage you to do last time, I
> hope what we expect is cleaerer now.
> 
> Thank you.

Hi,

before we do another few tries, I would send series split up as follows

1) fixes - ~12 patches
2) phy related stuff - 5 patches
3) irq grouping/fixes - 4 patches

or would you want me to split he ~12 fixes patches up aswell ?

	John
