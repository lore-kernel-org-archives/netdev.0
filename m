From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] iputils ping,ping6: use monotonic clock to schedule pings
Date: Tue, 21 Sep 2010 14:40:28 +0900
Message-ID: <4C98454C.6000602@linux-ipv6.org>
References: <alpine.DEB.1.10.1009051453090.13886@red.crap.retrofitta.se> <4C839797.50607@computer.org> <alpine.DEB.1.10.1009051521120.13886@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Jan Ceuleers <jan.ceuleers@computer.org>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:55781 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752146Ab0IUFlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 01:41:07 -0400
In-Reply-To: <alpine.DEB.1.10.1009051521120.13886@red.crap.retrofitta.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

(2010/09/05 22:25), Thomas Habets wrote:
> This fixes the problem where when time is set backwards 'ping' appears
> to freeze until the walltime catches up with the previously set time.
> 
> Adds dependency on librt.

Why don't we convert most (if not all) gettimeofday(), then?

--yoshfuji
