From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15091] New: starfire causes kernel BUG when
 interface goes up
Date: Mon, 25 Jan 2010 17:51:41 -0800
Message-ID: <20100125175141.cf53de2b.akpm@linux-foundation.org>
References: <bug-15091-10286@http.bugzilla.kernel.org/>
	<20100125170816.db9435ed.akpm@linux-foundation.org>
	<4B5E48FF.2050406@moffatt.org.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Michael <michael@moffatt.org.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50498 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752915Ab0AZBv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 20:51:58 -0500
In-Reply-To: <4B5E48FF.2050406@moffatt.org.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jan 2010 14:44:31 +1300 Michael <michael@moffatt.org.nz> wrote:

> Hi Andrew,
> 
> I believe that this is a regression, yes.
> 
> I will attempt to compile up some kernels this week and provide more 
> info. Should I start at 26 and go up or at 31 and go down?
> 
> I can't use anything lower than 26 according to udev. I was running 24 
> but compiled 32 when I upgraded udev.
> 

Thanks.

Starfire is a pretty rarely-used driver, I suspect.  Hopefully someone
who understands the NAPI stuff can look at the code and go "ah-hah",
and save you all that work.

But if that doesn't happen then yup, a bisection would be good, thanks.
 The best way to do it really is with git. 
http://landley.net/writing/git-quick.html has an explanation.



