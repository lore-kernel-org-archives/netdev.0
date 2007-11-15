From: "Jon Nelson" <jnelson@jamponi.net>
Subject: Re: tg3: strange errors and non-working-ness
Date: Thu, 15 Nov 2007 14:21:01 -0600
Message-ID: <cccedfc60711151221p322894f8i94c540fefb0e4827@mail.gmail.com>
References: <20071115094728.GB2366@ff.dom.local> <1195154603.6360.9.camel@dell>
	 <cccedfc60711151117v70b285fbl79bbc92ced176d54@mail.gmail.com>
	 <1195158200.6360.17.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:27859 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754190AbXKOUVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 15:21:04 -0500
Received: by nf-out-0910.google.com with SMTP id g13so600166nfb
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2007 12:21:02 -0800 (PST)
In-Reply-To: <1195158200.6360.17.camel@dell>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/15/07, Michael Chan <mchan@broadcom.com> wrote:
> On Thu, 2007-11-15 at 13:17 -0600, Jon Nelson wrote:
>
> > Is this what you mean? I pulled this from the quoted text:
> >
> > Nov 10 22:45:52 frank kernel: NETDEV WATCHDOG: eth0: transmit timed out
> >
>
> Right.  This explains the reset at 22:45:52, but not the earlier reset
> at 22:24:40.  Link never came up after that earlier reset.
>
> Is this a new problem introduced by a new driver?  I notice you are
> using tg3 3.65.  Have you used newer versions or older versions?

This is not a new problem - these cards have done this or something
like it for as long as I've had them*. They work just fine in 100 MBit
mode but not in all of my machines, and in none of them at gig-e.
I've tried every version of the driver since SUSE 9.1 without much
luck (at least as far back as 2.6.9). I'd try a newer driver, esp. if
I could make it compile on 2.6.22.12 (I prefer but do not require to
stay with the stock distro kernel, modules notwithstanding).

NOTE: to avoid list noise, I can make a bug out of this on
bugzilla.kernel.org and we can proceed from there if that is
preferred.

[*] Actually, they worked OK in 2.4.something way-back-when but only
for short durations at gig-e speeds.

-- 
Jon
