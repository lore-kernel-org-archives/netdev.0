From: Tom Marshall <tom@cyngn.com>
Subject: Re: [PATCH] net: ip: Do not allow connection to remote port zero
Date: Thu, 12 Feb 2015 07:34:39 -0800
Message-ID: <20150212153439.GA25134@eden.sea.cyngn.com>
References: <20150212005844.GB3829@nwwn.com>
 <1423713974.4942.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150212052428.GB10785@eden.sea.cyngn.com>
 <20150212062335.GA12626@eden.sea.cyngn.com>
 <54DCB082.2040207@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:46488 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150AbbBLPem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 10:34:42 -0500
Received: by mail-pa0-f48.google.com with SMTP id eu11so12119281pac.7
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 07:34:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54DCB082.2040207@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 12, 2015 at 04:54:10PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 2/12/2015 9:23 AM, Tom Marshall wrote:
> 
> >>* UDP packets with dport=0 are already prevented from being sent.
> 
> >FYI, I tried to trace where this code (disallowing udp packets with dport=0)
> >came from.  It predates git history, and I don't have any way to access
> >anything prior.
> 
>    Tried https://git.kernel.org/cgit/linux/kernel/git/tglx/history.git/?

Thanks, I didn't know about that.

The logic predates that tree also.  Which means prior to 2.5.0 or so.
