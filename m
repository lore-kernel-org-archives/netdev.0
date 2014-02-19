From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] net: tcp: add mib counters to track zero window
 transitions
Date: Wed, 19 Feb 2014 10:49:47 -0800
Message-ID: <1392835787.18849.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392674268-26005-1-git-send-email-fw@strlen.de>
	 <20140219.131708.562226572566677127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:40502 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754121AbaBSStt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 13:49:49 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so740522pde.0
        for <netdev@vger.kernel.org>; Wed, 19 Feb 2014 10:49:48 -0800 (PST)
In-Reply-To: <20140219.131708.562226572566677127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-19 at 13:17 -0500, David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Mon, 17 Feb 2014 22:57:48 +0100
> 
> > Three counters are added:
> > - one to track when we went from non-zero to zero window
> > - one to track the reverse
> > - one counter incremented when we want to announce zero window.
> > 
> > The latter is added because it can show cases where we want to close the
> > window but can't because we would shrink window.
> > 
> > Suggested-by: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> >  Eric, is this what you had in mind?
> > 
> >  I re-ran my 'slow-sender-with-reader-that-does-not-drain-socket'
> >  scenario and, as expected, only TCPWANTZEROWINDOW increases.
> 
> Eric, ping?

Thanks, I missed this patch. Let me think about it, thanks !
