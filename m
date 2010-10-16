From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 19692] New: linux-2.6.36-rc5 crash with
 gianfar ethernet at full line rate traffic
Date: Sat, 16 Oct 2010 21:48:15 +0200
Message-ID: <20101016194815.GA1894@del.dom.local>
References: <20101010103236.GA1919@del.dom.local>
 <20101015085853.GA8091@ff.dom.local>
 <AANLkTinAj=9-RqNA6xKc_5ONz2hPMRGM8uJ2Xy7XJVdr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Anton Vorontsov <avorontsov@mvista.com>
To: emin ak <eminak71@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39275 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079Ab0JPTsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 15:48:21 -0400
Received: by wyb28 with SMTP id 28so1764478wyb.19
        for <netdev@vger.kernel.org>; Sat, 16 Oct 2010 12:48:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTinAj=9-RqNA6xKc_5ONz2hPMRGM8uJ2Xy7XJVdr@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 16, 2010 at 02:14:01AM +0300, emin ak wrote:
> Hi Jarek.
> Sorry for delayed answer. As I promised, I have started the tests on
> Monday (in spite of dealing with The Monday Syndrome:)  I had applied
> your patch and after two billions packet (and approximatly four hours)
> passed kernel crashed with skb_over_panic error similar with first
> type. To ensure the patch is failed or not, I rerun the same test
> again. That time, surprisingly,  it did'nt crashed again for two days
> with same kernel. But this situation had occured before, I think
> sometimes because of randomness of the applied ethernet traffic and
> mostly because I cant apply all full line rate random traffic to my
> target device because of wrong test setup (switch / hardware packet
> generator settings etc..), it takes three or more day to crash the
> kernel and sometimes it never crashes. My device only and only crashes
> when I can apply full line rate random traffic. Before informing you
> and the list with (official) test results, I want to be sure with the
> truth of them. So that please let me apply more test to the target
> device for  a fews day more. After that I wish I'll came with good
> news!

Hi Emin,
Sorry for being impatient. Actually, waiting is no problem for me. I
simply didn't know how much this bug is reproducible, and was a bit
mislead by your forecast of one day result (and terrified btw seeing
words Monday and immediately side by side ;-) So, a few days or weeks,
no problem, it's all up to you.

On the other hand, it looks like there might be something else/more,
so I'd suggest to add this last skb_over_panic to bugzilla too.

Thanks,
Jarek P.
