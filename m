From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: DSCP of ICMPv6 Echo Reply not copied from Echo Request
Date: Fri, 10 Jan 2014 05:40:49 +0100
Message-ID: <20140110044049.GC1012@order.stressinduktion.org>
References: <trinity-4fd0752d-8ed9-432f-aa23-28055f886c4a-1389191682248@3capp-gmx-bs32>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Simon Schneider <simon-schneider@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53091 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaAJEku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 23:40:50 -0500
Content-Disposition: inline
In-Reply-To: <trinity-4fd0752d-8ed9-432f-aa23-28055f886c4a-1389191682248@3capp-gmx-bs32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Wed, Jan 08, 2014 at 03:34:42PM +0100, Simon Schneider wrote:
> with kernel version 2.6.33.32, I noticed for ping6 that the DSCP valu=
e of an Echo Request is not used for the corresponding Echo Reply.
> =C2=A0
> With ICMPv4, this is the case and I think it makes sense.
> =C2=A0
> This is not mandated by ICMP RFCs, but there are good reasons to use =
the same DSCP in both directions.

Yes, IMHO we should do that, especially because DSCP is sometimes used =
for
policy routing.

> Is there a specific reason for this difference between v4 and v6?
> =C2=A0
> Or was it even fixed in some newer kernel version?

Quick test showed no, I'll follow-up on this soon.

Greetings,

  Hannes
