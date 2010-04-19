From: David Miller <davem@davemloft.net>
Subject: Re: tip: origin tree build failure, [patch] fix isdn/gigaset build
 failure
Date: Mon, 19 Apr 2010 12:06:00 -0700 (PDT)
Message-ID: <20100419.120600.82034948.davem@davemloft.net>
References: <20100419180520.GA9244@elte.hu>
	<alpine.LFD.2.00.1004191112550.14500@i5.linux-foundation.org>
	<alpine.LFD.2.00.1004191200050.14500@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, tilman@imap.cc, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1004191200050.14500@i5.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 19 Apr 2010 12:00:49 -0700 (PDT)

> On Mon, 19 Apr 2010, Linus Torvalds wrote:
>> 
>> Maybe add the #include <linux/sched.h> into gigaset.h, instead of 
>> common.c?
> 
> This compiled for me, although the only thing I tried was just turning all 
> the gigaset options to 'y'. Maybe some other config doesn't work. So I 
> committed it as likely to fix things.

Thanks Linus.

Ingo, let us know if there is still some problems in your
build tests.
