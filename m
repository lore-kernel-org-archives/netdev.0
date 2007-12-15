From: "Ray Lee" <ray@madrabbit.org>
Subject: Re: Regression: Wireshark sees no packets in 2.6.24-rc3
Date: Fri, 14 Dec 2007 23:09:35 -0800
Message-ID: <2c0942db0712142309v15f79068m8c033180d41b9be@mail.gmail.com>
References: <2c0942db0712131746s7da91f2bkf45b3e1ddf16d1f3@mail.gmail.com>
	 <200712150305.02589.rjw@sisk.pl> <47633ECC.3020804@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: "Gabriel C" <nix.or.die@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.232]:14359 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815AbXLOHJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 02:09:37 -0500
Received: by hu-out-0506.google.com with SMTP id 19so563040hue.21
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2007 23:09:35 -0800 (PST)
In-Reply-To: <47633ECC.3020804@googlemail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 14, 2007 6:41 PM, Gabriel C <nix.or.die@googlemail.com> wrote:
> Rafael J. Wysocki wrote:
> > On Friday, 14 of December 2007, Ray Lee wrote:
> >> tshark -i eth0, eth1, lo are all empty. Works under 2.6.23.0 just
> >> fine. A quick scan of the log between 2.6.24-rc3 and current tip
> >> (-rc5) doesn't show any obvious fixes, but then again, what do I know.
> >> I'll check current tip on the weekend when I'll have the luxury to
> >> have my main system down long enough for a test. Right now I'm kinda
> >> up against a deadline, but didn't want to leave it unreported. Should
> >> be easy for someone else to confirm or deny whether current tip has
> >> the problem.
> >
> > FYI, I have created a bugzilla entry for this issue at:
> > http://bugzilla.kernel.org/show_bug.cgi?id=9568
>
> Hmm what do you mean by empty ? it does not capturing anything on that interface ?

Correct, absolutely no traffic. So if it works for you, then either
it's something that got fixed between -rc3 and -rc5, or something odd
when I did a make oldconfig, I suppose. (Or because I'm on an x86-64
kernel?) Regardless, -rc5 is currently building, and I'll try it in
the morning.

> I do run -rc5-git with wireshark-0.99.6 and tshark -i eth0 or lo works here.

Excellent. Thank you for checking!

Rafael: I'll update the bugzilla as warranted after testing.

Ray
