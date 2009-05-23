From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy for high speed (and bonding)
Date: Sat, 23 May 2009 18:02:07 +0200
Message-ID: <20090523160207.GB2896@ami.dom.local>
References: <1242857245.13519.17.camel@hazard2.francoudi.com> <4A148838.8010809@cosmosbay.com> <20090521072050.GA2892@ami.dom.local> <20090521074400.GA19113@francoudi.com> <20090521082805.GB2892@ami.dom.local> <1243075052.27210.22.camel@hazard2.francoudi.com> <20090523143432.GA2766@ami.dom.local> <20090523150630.GA4228@francoudi.com> <20090523153525.GA2896@ami.dom.local> <20090523155321.GA4752@francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:63033 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209AbZEWQDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2009 12:03:46 -0400
Received: by fxm12 with SMTP id 12so431375fxm.37
        for <netdev@vger.kernel.org>; Sat, 23 May 2009 09:03:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090523155321.GA4752@francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 23, 2009 at 06:53:21PM +0300, Vladimir Ivashchenko wrote:
> > > > > So, I got rid of bonding completely and instead configured PBR on Cisco
> > > > > + Linux routing in such a way so that packet gets received and
> > > > > transmitted using NICs connected to the same pair of cores with common
> > > > > cache. 65-70% idle on all cores now, compared to 0-30% idle in worst
> > > > > case scenarios before.
...
> > There is not enough data to analyse this, but generally you should aim
> > at maintaining one flow (RX + TX) on the same cpu cache.
> 
> Yep, that's what I did in the end (as per the top paragraph).

So, stop writing: "I'm completely ignorant in internals of kernel
operation" because you're smp expert now! ;-)

Jarek P.
