From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: dynamic TCP algorithms switching
Date: Sat, 23 Nov 2013 16:42:20 -0800
Message-ID: <20131123164220.0992c445@nehalam.linuxnetplumber.net>
References: <CAAVq3rnxE92PsJOChr+H52k5QfG7E=hAjsohK4Um0ZRO9TdYuA@mail.gmail.com>
	<20131122145621.344fa999@nehalam.linuxnetplumber.net>
	<CAAVq3rnmWUAzDGy9_nMLsbx++opgZpuYtG34VpZEBbJ2psBnZw@mail.gmail.com>
	<20131122155303.68da12ec@nehalam.linuxnetplumber.net>
	<CAAVq3rmgzL4Hg__dSkmEM75ZHuEsebE1D4ko-viSEggcYdrPjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yan cui <ccuiyyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:40005 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756390Ab3KXAmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 19:42:24 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so3225047pdj.16
        for <netdev@vger.kernel.org>; Sat, 23 Nov 2013 16:42:24 -0800 (PST)
In-Reply-To: <CAAVq3rmgzL4Hg__dSkmEM75ZHuEsebE1D4ko-viSEggcYdrPjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Nov 2013 22:56:10 -0500
yan cui <ccuiyyan@gmail.com> wrote:

> Thanks for the quick reply!
> Do you have the real-world workload results that demonstrate
> that cubic has the best performance among all the available congestion
> algorithms? If so, could you please post some?
> 
> 
> Thanks, Yan
> 
> 
> 2013/11/22 Stephen Hemminger <stephen@networkplumber.org>:
> > On Fri, 22 Nov 2013 18:21:12 -0500
> > yan cui <ccuiyyan@gmail.com> wrote:
> >
> >> Then, why include so many (current Linux has 10+ TCP congestion algorithms)
> >> algorithms? For users who want to deploy their application on Linux
> >> and if the applications
> >> are system resource intensive, they always want to tune the
> >> configurations of the operating systems for the last piece of
> >> performance. If they do so, maybe they are confused
> >> about which TCP congestion algorithm to use for their environment. So,
> >> the only way is to try each algorithm one by one. I understand the
> >> setting of the default TCP congestion
> >> algorithm to be Cubic means that it works well for most environments.
> >> But if others
> >> are seldom used, or can be replace with another implementation.
> >> Why not just remove from the kernel?
> >>
> >> Yan
> >
> > Most are intended for research and testing only.
> > Only a few are worth considering in a production environment.
> > That is also why there so many qdisc algorithms as well.
> >
> 
> 
> 

If you did a little searching around, you would find that there has been extensive
research in this area. http://netsrv.csc.ncsu.edu/wiki/index.php/TCP_Testing
is a good place to start.
