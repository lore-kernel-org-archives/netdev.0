From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Tue, 15 Sep 2009 07:29:34 +0200
Message-ID: <4AAF263E.9010405@gmail.com>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1> <4AA7E082.90807@gmail.com> <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1> <4AA963A4.5080509@gmail.com> <4AA97183.3030008@gmail.com> <alpine.DEB.1.10.0909101741520.9964@V090114053VZO-1> <alpine.DEB.1.10.0909141708150.8051@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59555 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbZIOFaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 01:30:05 -0400
In-Reply-To: <alpine.DEB.1.10.0909141708150.8051@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> Where are we on this? Definitely a regression?

??

I tried to reproduce your numbers and failed on my machines.

2.6.31 is actually faster than 2.6.22 on the bench you provided.

Must be specific to the hardware I guess ?


As text size presumably is bigger in 2.6.31, fetching code
in cpu caches to handle 10 packets per second is what we call
a cold path anyway.

If you want to make it a fast path, you want to make sure code its
always hot in cpu caches, and find a way to inject packets into
the kernel to make sure cpu keep the path hot.

