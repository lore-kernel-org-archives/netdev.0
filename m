From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem with ICMP rate limiting and redirects
Date: Thu, 01 Oct 2015 13:53:02 -0700
Message-ID: <1443732782.32531.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACOGZ=uKqPpNBWuuJox1JTCC5e0G_j4KG+zFA_Ykr8wHj4jPgA@mail.gmail.com>
	 <1443631374.32531.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CACOGZ=vM6N3J5voA=-zGYwedx9s6Bt7iwR3f-SwEdVOEPP6T9g@mail.gmail.com>
	 <1443646098.32531.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CACOGZ=tHZ0w0GhY9n+3pzCPBGZrBM-16q3455Du7w69+et4RvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hugo Vasconcelos Saldanha <hugovs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36335 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210AbbJAUxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 16:53:05 -0400
Received: by pablk4 with SMTP id lk4so84242522pab.3
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 13:53:04 -0700 (PDT)
In-Reply-To: <CACOGZ=tHZ0w0GhY9n+3pzCPBGZrBM-16q3455Du7w69+et4RvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-01 at 15:38 -0300, Hugo Vasconcelos Saldanha wrote:

> Thanks for pointing that out.
> 
> But how should all the sysctl's that control ICMP messages sent to
> specific targets (icmp_ratelimit, redirect_load, redirect_number,
> redirect_silence, error_cost and error_burst) be treated without
> relying on inetpeer? Entries in ip_idents hash don't represent
> specific targets. Am I missing something?


You could still rely on inetpeer if its size is controlled and capped.

And then fallback to ip_idents hash if inetpeer tree gets too big.

Best effort would be enough.
