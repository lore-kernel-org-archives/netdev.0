From: figo zhang <figo1802@gmail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Wed, 3 Mar 2010 09:46:31 +0800
Message-ID: <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	 <4B8D1C02.1010204@softplc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Yegor Yefremov <yegorslists@googlemail.com>,
	netdev@vger.kernel.org, zealcook@gmail.com
To: Dick Hollenbeck <dick@softplc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:38819 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701Ab0CCBqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 20:46:32 -0500
Received: by pwj8 with SMTP id 8so556663pwj.19
        for <netdev@vger.kernel.org>; Tue, 02 Mar 2010 17:46:31 -0800 (PST)
In-Reply-To: <4B8D1C02.1010204@softplc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/3/2 Dick Hollenbeck <dick@softplc.com>:
> Yegor Yefremov wrote:
>>
>> I'm using 2.6.33 kernel and I noticed such a strange behavior:
>>
>> after system start I transfer one file via netcat from my development
>> host, after this transfer the network is not functioning i.e. no pings
>> possible etc.
>>
>> To narrow down the problem I checked out this commit
>>
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=451f14439847db302e5104c44458b2dbb4b1829d.
>> Till here the network driver is functioning as intended, but after
>> NAPI introduction I have this issue. With latest git-pull of "Linus'
>> kernel tree" I can't even ping right after the systems start.
>>
>> Any Ideas? What am I missing?
>>
>
> No idea, although I am using the same ARM chip, my kernel is at 2.6.30.5,
> and except for this occasional loss of connection I get, the ethernet driver
> seems to work better than what you are reporting.

from linux-2.6.32, this ethernet  driver have add NAPI support, would
you like to
try using this version?
