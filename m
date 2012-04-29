From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic, inconsistent lock, vanilla 3.3.4, 32bit, tcp
Date: Sun, 29 Apr 2012 10:17:47 +0200
Message-ID: <1335687467.2900.70.camel@edumazet-glaptop>
References: <04009a9cbb27bf97cb7d86612191b751@visp.net.lb>
	 <1335684762.2900.69.camel@edumazet-glaptop>
	 <6e1a75b751372f0ca5a58c2d0122a3cc@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Glauber Costa <glommer@parallels.com>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:36138 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab2D2IRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2012 04:17:53 -0400
Received: by wejx9 with SMTP id x9so1246937wej.19
        for <netdev@vger.kernel.org>; Sun, 29 Apr 2012 01:17:52 -0700 (PDT)
In-Reply-To: <6e1a75b751372f0ca5a58c2d0122a3cc@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-04-29 at 11:00 +0300, Denys Fedoryshchenko wrote:
> On 2012-04-29 10:32, Eric Dumazet wrote:
> > On Sun, 2012-04-29 at 00:45 +0300, Denys Fedoryshchenko wrote:
> >> Hi
> >>
> >> Just got repeatable kernel panic on loaded proxy server
> >>
> >> Here is the log:
> 
> >>
> >> ---
> >> Denys Fedoryshchenko
> >
> > Seems to be related to Glauber Costa work
> >
> > sk_memory_allocated_add() seems to assume __percpu_counter_add() is 
> > irq
> > safe (truth is : it is not safe)
> 
> Not sure if it is related, but at my case, CONFIG_CGROUPS is not set
> 


Hmm, so its an old bug...

I'll take a look, thanks a lot !

(I am going to reply on your new thread since its better formatted)
