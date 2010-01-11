From: "Berck E. Nash" <flyboy@gmail.com>
Subject: Re: [Bug #14925] sky2 panic under load
Date: Mon, 11 Jan 2010 14:02:40 -0700
Message-ID: <4B4B91F0.1090902@gmail.com>
References: <wnS54-l8PVO.A.TlF.oMlSLB@chimera> <4B4A729E.9060805@gmail.com> <20100111132647.GA11193@ff.dom.local> <201001112032.24243.rjw@sisk.pl> <20100111203128.GA3139@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:51539 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882Ab0AKVCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 16:02:44 -0500
Received: by yxe17 with SMTP id 17so20683887yxe.33
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2010 13:02:43 -0800 (PST)
In-Reply-To: <20100111203128.GA3139@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Mon, Jan 11, 2010 at 08:32:24PM +0100, Rafael J. Wysocki wrote:
>> On Monday 11 January 2010, Jarek Poplawski wrote:
>>> On Sun, Jan 10, 2010 at 05:36:46PM -0700, Berck E. Nash wrote:
>>>> Rafael J. Wysocki wrote:
>>>>> This message has been generated automatically as a part of a report
>>>>> of recent regressions.
>>>>>
>>>>> The following bug entry is on the current list of known regressions
>>>>> from 2.6.32.  Please verify if it still should be listed and let me know
>>>>> (either way).
>>> BTW, I don't know why Berck didn't experience such a panic before
>>> 2.6.32, but seems not a regression to me. There might be new/more sky2
>>> TX timeouts which trigger this panic and would make a real regression.
>> Even if the code has always been broken, but it's only become visible after
>> 2.6.32, that still counts as a regression IMO, because now the users are
>> affected who weren't before.
> 
> Right, but:
> 1) someone with a similar but older problem might be mislead a fix is
>    not for them;
> 2) someone with exactly this one problem (i.e. Berck ;-) might be
>    mislead "no oops" is enough, while their linux might be still worse
>    than before. (So I intended Berck to re-consider or even re-check
>    this problem wrt. 2.6.31, and maybe even reporting another
>    regression.)

Well, the problem with this bug is how hard it is for me to reproduce.
I'm willing to admit that just because I never got it before 2.6.32
isn't proof that it wasn't there in 2.6.31.  But it's a regression
somewhere along the line, since I've been using this hardware for over 3
years now.  There were lots of bugs in the sky2 driver years ago, but
for the last 2+ years or so, I haven't had any trouble at all until now.

The bug only shows up for me with bittorrent traffic.  I also use the
same adapter to transfer backups over the network from several
computers, and that doesn't trigger it...

I used 2.6.31 for however long it was the current stable, and I never
got a crash with it.  After I got several crashes in 2.6.32, I reverted
to 2.6.31 until Jarek sent this patch that seems to have fixed it.  I've
never gotten it to crash in 2.6.31, so I'm pretty sure it's a 2.6.32
regression, but I can't prove it.

I would love to do more testing, but since I can't reproduce the bug at
will, I'm not really sure what to offer?
