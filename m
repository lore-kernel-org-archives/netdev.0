From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.20-rc1 sky2 problems (regression?)
Date: Fri, 15 Dec 2006 17:25:20 -0800
Message-ID: <20061215172520.62022520@freekitty>
References: <87mz5qnf5q.fsf@sycorax.lbl.gov>
	<E1Gv2kS-0002QY-00@gondolin.me.apana.org.au>
	<20061214192218.35a7f8e1@localhost.localdomain>
	<878xh9rf06.fsf@sycorax.lbl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:33851 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030422AbWLPBZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 20:25:56 -0500
To: Alex Romosan <romosan@sycorax.lbl.gov>
In-Reply-To: <878xh9rf06.fsf@sycorax.lbl.gov>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Dec 2006 19:53:45 -0800
Alex Romosan <romosan@sycorax.lbl.gov> wrote:

> Stephen Hemminger <shemminger@osdl.org> writes:
> 
> > I have a fixed up version of the vendor driver, I'll repackage it tomorrow.
> 
> as per the include file, i ended up replacing all the CHECKSUM_HW with
> CHECkSUM_PARTIAL since the functions in questions had to do with
> transmit. seems to be working so far without any lockups. we'll see
> how long this lasts.
> 
> --alex--
> 

I fixed a bunch of stuff (see ChangeLog) and made a 2.6.19 or later
version see:
	http://developer.osdl.org/shemminger/prototypes/sk98lin-8.41.tar.gz

It is too noisy in the console log, because it shows how many times
the driver dope slaps itself senseless...  Basically every 250ms when
it is idle it resets, sorry it's the kind of code you right to "make it work"
and ship it which is why vendor drivers suck.

-- 
Stephen Hemminger <shemminger@osdl.org>
