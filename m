From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2 1/2] syncookies: remove ecn_ok validation when
 decoding option timestamp
Date: Fri, 31 Oct 2014 07:04:47 -0700
Message-ID: <1414764287.27538.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414757602-27637-1-git-send-email-fw@strlen.de>
	 <1414757602-27637-2-git-send-email-fw@strlen.de>
	 <1414762333.499.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141031133948.GJ10069@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34061 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759357AbaJaOEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 10:04:49 -0400
Received: by mail-ie0-f169.google.com with SMTP id tr6so1314279ieb.14
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 07:04:48 -0700 (PDT)
In-Reply-To: <20141031133948.GJ10069@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-31 at 14:39 +0100, Florian Westphal wrote:

> It would only get enabled if the echoed timestamp (ie the timestamp we
> sent in the synack) indicates that ecn was enabled, i.e. the client or
> a middlebox would have to munge/modify it to set the 'ecn on' bit in the
> timestamp.
> 
> If that is too fragile in your opinion I will respin the patch to include
> the additional validation via dst.  We already need to fetch the dst
> object anyway to fetch certain route attributes not in the timestamp or
> cookie, so its only a matter of reorganizing code first to avoid two lookups.

Well, your changelog is so confusing, I have no idea what is your
intent.

I do not really understand why you need to change something.

Maybe this is because I have not yet took my coffee ;)

Thanks
