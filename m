From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 08/12] ptp: Added a brand new class driver for ptp
 clocks.
Date: Fri, 13 Aug 2010 11:34:38 +0200
Message-ID: <20100813093438.GA18112@riccoc20.at.omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
 <4a030d2bace90f089f2f3f61496b918c6f1dfb52.1276615626.git.richard.cochran@omicron.at>
 <AANLkTinYjzfChsN0AB5W6kOh6xJYPJtoEq941pG8WbmS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Thomas Gleixner <tglx@linutronix.de>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52631 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934042Ab0HMJeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 05:34:31 -0400
Received: by fxm13 with SMTP id 13so1477437fxm.19
        for <netdev@vger.kernel.org>; Fri, 13 Aug 2010 02:34:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTinYjzfChsN0AB5W6kOh6xJYPJtoEq941pG8WbmS@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 01:11:30PM -0600, Grant Likely wrote:
> On Tue, Jun 15, 2010 at 10:09 AM, Richard Cochran
> > +static DEFINE_SPINLOCK(clocks_lock); /* protects 'clocks' */
> 
> Doesn't appear that clocks is manipulated at atomic context.  Mutex instead?
...
> If the spinlock is changed to a mutex that is held for the entire
> function call, then the logic here can be simpler.

Grant,

I am working on another go at this patch series. Stupid question:

The caller of ptp_clock_register(), which takes the clocks_lock, is
always a module_init() function. Is this always a safe context in
which to call mutex_lock?

Thanks,

Richard

