From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: What is lock_sock() before skb_free_datagram() for?
Date: Sat, 18 Apr 2009 10:09:57 +0200
Message-ID: <49E98AD5.2010008@cosmosbay.com>
References: <200904181704.FDC21361.FQLOFHOOSVFtMJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44441 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756747AbZDRIKC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 04:10:02 -0400
In-Reply-To: <200904181704.FDC21361.FQLOFHOOSVFtMJ@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tetsuo Handa a =E9crit :
> Hello.
>=20
> udp_recvmsg() and udpv6_recvmsg() call skb_free_datagram() with=20
> lock_sock().
> But raw_recvmsg() and rawv6_recvmsg() call skb_free_datagram()=20
> without
> lock_sock().
> Is it OK?

Yes it is.

UDP protocol has memory accounting in recent kernels, not RAW.


