From: emin ak <eminak71@gmail.com>
Subject: Re: [Bugme-new] [Bug 19692] New: linux-2.6.36-rc5 crash with gianfar
 ethernet at full line rate traffic
Date: Sat, 16 Oct 2010 02:14:01 +0300
Message-ID: <AANLkTinAj=9-RqNA6xKc_5ONz2hPMRGM8uJ2Xy7XJVdr@mail.gmail.com>
References: <20101010103236.GA1919@del.dom.local>
	<20101015085853.GA8091@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Anton Vorontsov <avorontsov@mvista.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:63030 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257Ab0JOXOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 19:14:03 -0400
Received: by vws2 with SMTP id 2so557002vws.19
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 16:14:01 -0700 (PDT)
In-Reply-To: <20101015085853.GA8091@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Emin,
> Are there any problems with this testing?
>
> Jarek P.
>
Hi Jarek.
Sorry for delayed answer. As I promised, I have started the tests on
Monday (in spite of dealing with The Monday Syndrome:)  I had applied
your patch and after two billions packet (and approximatly four hours)
passed kernel crashed with skb_over_panic error similar with first
type. To ensure the patch is failed or not, I rerun the same test
again. That time, surprisingly,  it did'nt crashed again for two days
with same kernel. But this situation had occured before, I think
sometimes because of randomness of the applied ethernet traffic and
mostly because I cant apply all full line rate random traffic to my
target device because of wrong test setup (switch / hardware packet
generator settings etc..), it takes three or more day to crash the
kernel and sometimes it never crashes. My device only and only crashes
when I can apply full line rate random traffic. Before informing you
and the list with (official) test results, I want to be sure with the
truth of them. So that please let me apply more test to the target
device for  a fews day more. After that I wish I'll came with good
news!
Thanks for your time and care alot.
Emin
