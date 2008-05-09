From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Fri, 9 May 2008 12:28:39 +0200
Message-ID: <BAY103-DAV9DAC70A1FBBEECCCC05E4B2D30@phx.gbl>
References: <E1Jrtxr-0004in-00@gondolin.me.apana.org.au> <BAY103-DAV594320AC93E33D7335927B2DA0@phx.gbl> <BAY103-DAV122A113843FE9574256A0AB2D60@phx.gbl> <BAY103-DAV6446AEC1CBB678E5D0E52B2D30@phx.gbl> <20080509102509.GA11710@gondor.apana.org.au>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s31.bay0.hotmail.com ([65.54.246.103]:9561 "EHLO
	bay0-omc1-s31.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752715AbYEIKbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 06:31:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:

> On Fri, May 09, 2008 at 11:50:00AM +0200, Marco Berizzi wrote:
> >
> > I have rebooted the two boxes with slub_debug.
> > This is the output taken with network console.
> > Herbert does it help you?
> >
> > BUG: unable to handle kernel paging request at 6b6b6b9f
>
> Unfortunately this just confirms that your skb has been freed
> prematurely because 6b is the poison value.
>
> However, it doesn't point us at the offender.

:-((

> Although I wonder if there might be something in netfilter that's
> freeing it since that's the only thing that could've run on your
> machine between the previous access and the crash.  I'll take
> another look.

Let me know if the only solution is git bisect.
The bug is spotted when sch_sfq/_htb and cls_fw
are loaded.


