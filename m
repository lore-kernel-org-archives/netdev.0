From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Repeatable IPv6 crash in 3.19.0-1
Date: Fri, 27 Feb 2015 18:03:45 -0800
Message-ID: <1425089025.5130.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54F0E38C.5060203@vultr.com>
	 <1425084533.5130.54.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1425086169.5130.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54F11FC8.7010100@vultr.com>
	 <1425088894.5130.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brian Rak <brak@vultr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:40807 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbbB1CDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 21:03:47 -0500
Received: by iebtr6 with SMTP id tr6so35502826ieb.7
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 18:03:46 -0800 (PST)
In-Reply-To: <1425088894.5130.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 18:01 -0800, Eric Dumazet wrote:
> On Fri, 2015-02-27 at 20:54 -0500, Brian Rak wrote:
> 
> > Wow, that was *much* faster then I was expecting, thanks a bunch!
> > 
> > I can confirm that resolves the issue.. I've tested this and it fixes 
> > the issue perfectly.  I've been able to put a whole bunch of IPv6 
> > traffic through the interface now, whereas before even a minor amount of 
> > traffic would crash the host.
> > 
> > Thanks again!
> 
> Interesting...
> 
> Had a prior version of linux kernel been fine ?

Or maybe you recently switched on this config option ?

CONFIG_DEBUG_PAGEALLOC=y
