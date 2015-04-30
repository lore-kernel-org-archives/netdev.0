From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH] ss: Fix wrong filter behaviour
Date: Thu, 30 Apr 2015 10:26:55 +0300
Message-ID: <20150430072655.GA689@angus-think.wlc.globallogic.com>
References: <1430227008-7440-1-git-send-email-vadim4j@gmail.com>
 <20150428133745.GA10292@angus-think.wlc.globallogic.com>
 <55414B85.1070204@ionic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Mihai Moldovan <ionic@ionic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:33421 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbbD3H1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 03:27:21 -0400
Received: by layy10 with SMTP id y10so37599664lay.0
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 00:27:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55414B85.1070204@ionic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 11:22:13PM +0200, Mihai Moldovan wrote:
> On 28.04.2015 03:37 PM, Vadim Kochan wrote:
> > On Tue, Apr 28, 2015 at 04:16:48PM +0300, Vadim Kochan wrote:
> >> From: Vadim Kochan <vadim4j@gmail.com>
> >>
> >> Fixed applying family & socket type filters.
> >> It was not possible to select UDP & UNIX sockets together.
> >>
> >> Now selected families are ORed.
> >>
> >> The problem was that filters were combined by AND.
> >>
> >> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> >> Reported-By: Mihai Moldovan <ionic@ionic.de>
> >> ---
> >>  misc/ss.c | 91 ++++++++++++++++++++++++++++++++++-----------------------------
> >>  1 file changed, 49 insertions(+), 42 deletions(-)
> >>
> >> diff --git a/misc/ss.c b/misc/ss.c
> >> index 954a30b..46dbb39 100644
> >> [...]
> > 
> > Would you please respond if you received this patch ?
> > I am just checking, in case if it was get into 'Spam' list.
> > 
> > Regards,
> 
> I finally came around to testing this, sorry it took me so long.
> 
> Using that patch, the output looks much better. It works for my use case.
> 
> What do we do with the "broken" versions, though? Even if that patch hits 4.1.0,
> older versions like 4.0.0, 3.19.0 etc. will still be broken?
> 
> 
> 
> Mihai
> 

Hi Mihai,

I think it depends on distro package maintainers, usually they track the
upstream fixes and uses them in their stable versions, may be I should
grep some maintainers emails (LARTC mailing list ?) and broadcast to them ?

Regards,
