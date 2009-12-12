From: David Miller <davem@davemloft.net>
Subject: Re: nfs broken in net-next? -- now in mainline -- bisected:
 d9f5950f90292f7cc42834338dfd5f44dc4cc4ca
Date: Fri, 11 Dec 2009 21:41:17 -0800 (PST)
Message-ID: <20091211.214117.200029438.davem@davemloft.net>
References: <86802c440912112125v4aa72189ifcc2d16ecbf79cc4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, sri@us.ibm.com, herbert@gondor.apana.org.au,
	torvalds@linux-foundation.org, sjayaraman@suse.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: yhlu.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60931
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757439AbZLLFlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 00:41:11 -0500
In-Reply-To: <86802c440912112125v4aa72189ifcc2d16ecbf79cc4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinghai Lu <yhlu.kernel@gmail.com>
Date: Fri, 11 Dec 2009 21:25:49 -0800

> [linux-2.6]# git bisect good
> d9f5950f90292f7cc42834338dfd5f44dc4cc4ca is first bad commit
> commit d9f5950f90292f7cc42834338dfd5f44dc4cc4ca
> Author: Sridhar Samudrala <sri@us.ibm.com>
> Date:   Wed Oct 7 12:24:25 2009 +0000
> 
>     net: Make UFO on master device independent of attached devices

Thanks.

If I don't hear anything from Sridhar in a day or two I'll simply
revert that change.
