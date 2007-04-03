From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: r8169 doesn't work
Date: Wed, 04 Apr 2007 06:41:40 +0900
Message-ID: <87ejn13zl7.fsf@duaron.myhome.or.jp>
References: <87ircdtbkn.fsf@duaron.myhome.or.jp>
	<20070403212836.GA12963@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.parknet.jp ([210.171.160.80]:3607 "EHLO parknet.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431AbXDCVlq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 17:41:46 -0400
Received: from ibmpc.myhome.or.jp ([210.171.168.39]:3204)
	by parknet.jp with [XMail 1.21 ESMTP Server]
	id <S11CFF> for <netdev@vger.kernel.org> from <hirofumi@mail.parknet.co.jp>;
	Wed, 4 Apr 2007 06:42:20 +0900
In-Reply-To: <20070403212836.GA12963@electric-eye.fr.zoreil.com> (Francois Romieu's message of "Tue\, 3 Apr 2007 23\:28\:36 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> writes:

> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> :
> [...]
>> I have a r8169 problem, it seems RX doesn't work. To work r8169 for me
>> I'm needing to revert the following three commits now, but I don't
>> know why.
>> 
>>     9cb427b6ff0b3e235c518acf5c1fcbbfc95f0ae2
>>     12d86f682e8acad8555718dc7b0082590f2365d0
>>     cc9f022d97d08e4e36d38661857991fe91447d68
>
> (oh, the horror...)
>
>> Any idea?
>
> Figuring the last known working kernel version and the first broken one
> could help (which hardware ? x86_64 + SMP ?)

IIRC, First broken one was 9cb427b6ff0b3e235c518acf5c1fcbbfc95f0ae2.
To make sure, I'll confirm tomorrow.

> but I'd appreciate if you try beforehand the patches at:
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc5/r8169-20070402

Oh, thanks. I'll try.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
