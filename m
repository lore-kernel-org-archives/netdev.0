From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Thu, 22 Feb 2007 18:31:29 -0800
Message-ID: <f2b55d220702221831p23122caawa4f0fb4210a09b87@mail.gmail.com>
References: <f2b55d220702200749l4fa2b14foa861cf37288cfb8d@mail.gmail.com>
	 <20070222234900.27633.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, akepner@sgi.com, bcrl@kvack.org,
	dada1@cosmosbay.com, davem@davemloft.net, netdev@vger.kernel.org
To: "linux@horizon.com" <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.226]:5895 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbXBWCbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 21:31:33 -0500
Received: by wr-out-0506.google.com with SMTP id i21so356538wra
        for <netdev@vger.kernel.org>; Thu, 22 Feb 2007 18:31:32 -0800 (PST)
In-Reply-To: <20070222234900.27633.qmail@science.horizon.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22 Feb 2007 18:49:00 -0500, linux@horizon.com <linux@horizon.com> wrote:
> The rehash-every-10-minutes detail is theoretically unnecessary,
> but does cover the case where a would-be attacker *does* get a chance
> to look at a machine, such as by using routing delays to measure the
> effectiveness of a collision attempt.

AOL -- and that's one of the reasons why RCUing hashes is a nightmare
in practice, if you care about smooth peristalsis.  Again, the
resizing headache is just the canary in the coal mine.

> If you want to test your distribution for randomness, go have a look
> at Knuth volume 2 (seminumerical algorithms) and see the discussion of
> the Kolmogorov-Smirnov test.  Some lumpiness is *expected* in a truly
> random distribution.

Ah, Kolmogorov-Smirnov, the astronomer's friend.  Somewhere on a DAT
in my garage lies a rather nice implementation of K-S tests on
censored data for the Mirella/Mirage Forth image analysis package.  If
you want something industrial-strength, easy to use, and pretty
besides, I recommend SM (http://www.astro.princeton.edu/~rhl/sm/),
which will cost you $500 U.S. for a department-scale license.  SM so
utterly exceeds the capabilities of gnuplot it isn't even funny.  But
then, while you don't always get what you pay for, you rarely fail to
pay for what you get, sooner or later, in one currency or another.

Cheers,
- Michael
