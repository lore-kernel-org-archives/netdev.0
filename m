From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fix syncookie regression
Date: Tue, 13 Mar 2012 10:37:31 -0700
Message-ID: <1331660251.4449.24.camel@edumazet-glaptop>
References: <20120310122725.GA31129@hostway.ca>
	 <1331401490.2453.28.camel@edumazet-laptop>
	 <1331402182.2453.30.camel@edumazet-laptop>
	 <1331407221.2453.42.camel@edumazet-laptop>
	 <20120313072643.GA32306@hostway.ca>
	 <CADVnQynM5F=B60-7AMFHn0A9g-jvcBzo+dSg-C0isDBo_UMyjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Simon Kirby <sim@netnation.com>, netdev@vger.kernel.org
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:46859 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758059Ab2CMRhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 13:37:35 -0400
Received: by dadp12 with SMTP id p12so1304890dad.11
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 10:37:35 -0700 (PDT)
In-Reply-To: <CADVnQynM5F=B60-7AMFHn0A9g-jvcBzo+dSg-C0isDBo_UMyjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-03-13 at 12:44 -0400, Neal Cardwell wrote:

> Yes, exactly. 3.2.9 and 3.2.10 have
> daef52bab1fd26e24e8e9578f8fb33ba1d0cb412 but not the
> 4648dc97af9d496218a05353b0e442b3dfa6aaab that fixes the resulting
> issue with sacked_out going negative, and these lines you've flagged
> are exactly the symptoms we'd expect because of that. The fix is
> queued up for the -stable series already, so it should be in 3.2.11, I
> presume. The fix is already in 3.3-rc7.

3.2.12 more probably, as 3.2.11 is a single build fix
