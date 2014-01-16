From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Thu, 16 Jan 2014 10:49:06 -0800
Message-ID: <1389898146.31367.413.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389888898-31744-1-git-send-email-msekleta@redhat.com>
	 <52D80BCA.7030400@redhat.com> <20140116172631.GA5206@loki.brq.redhat.com>
	 <52D82626.5060701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	David Miller <davem@davemloft.net>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:49311 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbaAPStK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 13:49:10 -0500
Received: by mail-yh0-f46.google.com with SMTP id 29so1089537yhl.19
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 10:49:09 -0800 (PST)
In-Reply-To: <52D82626.5060701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-16 at 19:34 +0100, Daniel Borkmann wrote:

> > Thank you for the review. Btw, what do you think about define for parisc? I am
> 
> Yes, saw that in the patch and had similar thoughts.
> 
> > not sure I grok 0x4048 for SO_MAX_PACING_RATE and hence not sure about 0x4029
> > for SO_BPF_EXTENSIONS.
> 
> Hmm, maybe typo; SO_MAX_PACING_RATE should have been a 0x4028 ?

Indeed it was a typo.

I think its time to change this, as this was added for linux-3.13
