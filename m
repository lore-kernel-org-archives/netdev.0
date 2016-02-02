From: "Franklin S Cooper Jr." <fcooper@ti.com>
Subject: Re: Keystone 2 boards boot failure
Date: Tue, 2 Feb 2016 15:01:33 -0600
Message-ID: <56B1192D.1010500@ti.com>
References: <56B0DE61.2000704@ti.com> <4387314.e6bS94RE4H@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <m-karicheri2@ti.com>, <netdev@vger.kernel.org>, <w-kwok2@ti.com>,
	<davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:45136 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754946AbcBBVBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 16:01:41 -0500
In-Reply-To: <4387314.e6bS94RE4H@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/02/2016 02:41 PM, Arnd Bergmann wrote:
> On Tuesday 02 February 2016 10:50:41 Franklin S Cooper Jr. wrote:
>> Latest mainline is currently failing to boot for Keystone 2
>> Hawking but I'm assuming its true for other Keystone 2
>> boards. Bisect shows that this issue popped up after the
>> patch "netcp: try to reduce type confusion in descriptors"
>> (commit 89907779) was introduced. There was another patch
>> "netcp: fix regression in receive processing" that seems to
>> fix some bugs that the prior patch introduced however it
>> still did not resolve the boot failure and was documented as
>> not being tested.
>>
>> Should we revert these commits or does anyone have any
>> suggestions on how to fix these failures? I would be more
>> than happy to test any fix.
>>
> Have you tried to see if a revert fixes the problem on a
> current kernel?

Yes. Here is a boot log on the latest master with the below
three patches reverted.
http://pastebin.com/W7RWSHpE (Working)

I reverted these three patches. The two latest patches seem
to be trying to correct/expand upon the last patch on this list.

commit 958d104e3d40eef5148c402887138f6594ff7e1e
netcp: fix regression in receive processing

commit 9dd2d6c5c9755b160fe0111bcdad9491676feea8
netcp: add more __le32 annotations

commit 899077791403ff7a2d8cfaa87bd1a82d729463e2
netcp: try to reduce type confusion in descriptors



>
> 	Arnd
