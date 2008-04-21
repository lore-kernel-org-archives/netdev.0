From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Mon, 21 Apr 2008 20:21:06 +0200
Message-ID: <200804212021.06367.mb@bu3sch.de>
References: <bug-10473-10286@http.bugzilla.kernel.org/> <9bfa9ae0804181338q4a53fffdhe1833441794aed7@mail.gmail.com> <9bfa9ae0804211114h365be96ey3c763acfac63acb0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Nelson A. de Oliveira" <naoliv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:36538 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755079AbYDUSVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 14:21:46 -0400
In-Reply-To: <9bfa9ae0804211114h365be96ey3c763acfac63acb0@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 21 April 2008 20:14:44 Nelson A. de Oliveira wrote:
> This one is probably 2.6.23.
> After some time the system continued to boot, but without network interface.
> So marked it as bad.

That probably was a mistake

> What else can I do, please?

You can try latest git. I was told it has a feature
to tell bisect "I don't know" instead of "good" or "bad".
This can be used if a test kernel doesn't compile, or does
fail because of some other bug.

You can also manually bisect the stuff between your known-good
version of b44 and the bad one. There were only a couple of patches.
You can extract them with git and revert them one by one and see
when it does start working again.
I think it was something like 5 patches or so. Nothing too time consuming.

-- 
Greetings Michael.
