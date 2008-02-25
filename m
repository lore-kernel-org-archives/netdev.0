From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 25 Feb 2008 13:39:48 +0000
Message-ID: <20080225133948.GC4733@ff.dom.local>
References: <20080219230640.GA2755@ami.dom.local> <47BC4F2C.4000802@katalix.com> <20080220183837.GA2881@ami.dom.local> <47BCABC5.9080204@katalix.com> <20080221085959.GA12944@ff.dom.local> <47BD4A34.7070606@katalix.com> <20080221120829.GB12944@ff.dom.local> <47BDB030.1050105@gmail.com> <47C2B266.8070604@katalix.com> <20080225130508.GB4733@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.240]:33273 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbYBYNis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 08:38:48 -0500
Received: by hs-out-0708.google.com with SMTP id 54so1551196hsz.5
        for <netdev@vger.kernel.org>; Mon, 25 Feb 2008 05:38:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080225130508.GB4733@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 25, 2008 at 01:05:08PM +0000, Jarek Poplawski wrote:
...
> On Mon, Feb 25, 2008 at 12:19:50PM +0000, James Chapman wrote:
> > Is this an acceptable solution? If so, I'll prepare and send official  
> > patches.
> 
> IMHO this should be acceptable because I can't see any reason for
> changing properly working code if there is so simple and not costly
> solution. But maybe David or somebody else finds some cons? [...]

Hmm... Wait a minute! But on the other hand David has written about
his cons here, and it looks reasonable: this place would be fixed,
but some others can start reports like this. Maybe, it's better to
analyze yet if it's really so hard to eliminate taking this lock
on the xmit path?

Jarek P.
