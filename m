From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 06 Jun 2011 14:23:53 -0600
Message-ID: <4DED3759.7030209@genband.com>
References: <1307389540.2642.3.camel@edumazet-laptop> <20110606.130309.847468074358617705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og123.obsmtp.com ([64.18.2.24]:60532 "EHLO
	exprod7og123.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367Ab1FFU0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:26:36 -0400
In-Reply-To: <20110606.130309.847468074358617705.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2011 02:03 PM, David Miller wrote:
> From: Eric Dumazet<eric.dumazet@gmail.com>
> Date: Mon, 06 Jun 2011 21:45:40 +0200
>
>> While trying Alexander Holler patch, I found a 32bit brctl program was
>> not able to work on a 64bit kernel. So I had to switch to another
>> machine for my tests.
>>
>> brctl addbr mybridge
>> ->
>> socket(PF_FILE, SOCK_STREAM, 0)         = 3
>> ioctl(3, SIOCSIFBR, 0xffd509c0)         = -1 EINVAL (Invalid argument)
>>
>> Should we care or not ?
>
> I think we should make an effort to fix this.

For current status of affairs, this makes sense.

It raises an interesting question though...do we plan on supporting 
compat indefinitely?

As I see it x86 generally makes more sense to run as 64-bit when 
possible due to the extra register availability. Compat is primarily 
useful for the embedded space and for backwards compatibility, and 
ripping it out would cause a lot of grief for legacy 32-bit apps.  It 
would simplify the userspace/kernel interface though.

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
