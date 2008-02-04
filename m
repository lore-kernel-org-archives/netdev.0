From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: oops with ipcomp
Date: Mon, 4 Feb 2008 10:35:00 +0100
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD134F20A5@exch.facton.local>
References: <3C59DB883F7B0B4D8096010D45ACCD134F209E@exch.facton.local> <20080202044254.GA27792@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:33727 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940AbYBDJfK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 04:35:10 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080202044254.GA27792@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Unable to handle kernel paging request at ffffc200000fb000 RIP: 
>>  [<ffffffff8031b8f0>] deflate_slow+0x40/0x400

> I'm not able to get much information out of this crash dump.  Nor
> can I reproduce this bug on my 32-bit machines and I'm currently
> away from my 64-bit machines.

> How long have you been using IPComp in the past and what was the
> last kernel version which was stable with IPComp?

I've never seen this with kernels < 2.6.24 after many years of
ipsec/ipcomp usage.
I got it 18 hours after boot, since the oops it runs stable for further
72 hours.
But I cross the fingers that it was an unique issue, I'll report if it
oopses again.

Daniel
