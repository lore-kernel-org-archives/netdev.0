From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- revert for 2.6.26-rc1 failed
Date: Thu, 14 Aug 2008 11:29:53 -0700
Message-ID: <86802c440808141129t4399668bmc35def15e65fbe99@mail.gmail.com>
References: <798351.12728.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Bill Fink" <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org, "Ingo Molnar" <mingo@elte.hu>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:36702 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbYHNS3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 14:29:55 -0400
Received: by gxk9 with SMTP id 9so2647511gxk.13
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 11:29:54 -0700 (PDT)
In-Reply-To: <798351.12728.qm@web82105.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I do not know how to bisect with your patch if I have a "bad" but no "good"
> to start with.  Can you explain how I should proceed when I _do_ get home?
> (I can just enabled those config options and try the patch again, but I am
> confused about the bisect you are asking me to perform.)
>
just like the old way doing git-bisect, but before compiling, apply
the batch, and before git-bisect good or bad, revert the patch.

YH
