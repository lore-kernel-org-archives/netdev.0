From: Andres Freund <andres@anarazel.de>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (possibly	caused
 by netem)
Date: Thu, 02 Jul 2009 13:43:49 +0200
Message-ID: <4A4C9D75.5010300@anarazel.de>
References: <4A4A9DD6.8060800@anarazel.de> <4A4BAD5F.7050908@gmail.com> <4A4BD384.3090407@anarazel.de> <4A4C0144.5070203@anarazel.de> <20090702093031.GC4954@ff.dom.local> <20090702101207.GA7056@ff.dom.local> <4A4C95FC.7040305@anarazel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.anarazel.de ([217.115.131.40]:33658 "EHLO smtp.anarazel.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751928AbZGBLnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2009 07:43:47 -0400
In-Reply-To: <4A4C95FC.7040305@anarazel.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2009 01:11 PM, Andres Freund wrote:
> On 07/02/2009 12:12 PM, Jarek Poplawski wrote:
>> On Thu, Jul 02, 2009 at 09:30:31AM +0000, Jarek Poplawski wrote:
>>> On Thu, Jul 02, 2009 at 02:37:24AM +0200, Andres Freund wrote:
>>> ...
>>>> So I tried - and I did not catch any lockdep output before the crash.
>>>> Unfortunately I do not have another machine on the same local
>>>> network to
>>>> catch any messages after the crash... So I could be missing some
>>>> warning
>>>> (I did synchronous logging though).
>>>> Will check with netconsole tomorrow.
>>>
>>> Could you try if this patch changes anything?
>>
>> ...and maybe CONFIG_PACKET_MMAP turned off.
> Ok. Removed the skb_orphan and turned of CONFIG_PACKET_MMAP. Seemingly
> the same game.
> I now had another computer to catch the netconsole output. Still no
> lockdep warnings.
>
> Unfortunately the other computer was a windows machine with its strange
> terminal, so long lines are wrapped at 80cols, but that shouldn't be too
> bad.
I will start trying to place the issue by testing with existing kernels 
between 2.6.30 and now.

Andres
