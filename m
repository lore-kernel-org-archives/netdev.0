From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 07:50:52 -0700
Message-ID: <CA+55aFxoWLad9vtfAzQ7qXWcspL92D5s5+MFJ-HfyH3LVqfpaA@mail.gmail.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
 <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
 <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com>
 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
 <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk> <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
 <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	David Miller <davem@davemloft.net>, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:53382 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752833Ab2HVOvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 10:51:14 -0400
Received: by wicr5 with SMTP id r5so5798598wic.1
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 07:51:13 -0700 (PDT)
In-Reply-To: <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 22, 2012 at 7:24 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>
> Sorry, I'll paste it below.

The thing you pasted isn't actually the thing in the subject line.
It's just you *using* it.

I wanted to see what that "writeo()" looks like for x86-64.

But I got google to find it for me by looking for "__raw_writeo", so I
can see the patch now. It looks like it might work. Does it really
help performance despite always doing those TS games in CR0 for each
access?

                 Linus
