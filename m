From: Wolfgang Denk <wd@denx.de>
Subject: Re: [PATCH 1/2 v3] fs_enet/mii-fec.c: fix MII speed calculation
Date: Thu, 16 Jul 2009 23:21:29 +0200
Message-ID: <20090716212129.70710832E416@gemini.denx.de>
References: <1247578966-9847-1-git-send-email-wd@denx.de> <1247671133-12148-1-git-send-email-wd@denx.de> <fa686aa40907151017n76524708tdb028689adad4b5f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linuxppc-dev@ozlabs.org, Kumar Gala <galak@kernel.crashing.org>,
	netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:58429 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933388AbZGPVVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 17:21:33 -0400
In-reply-to: <fa686aa40907151017n76524708tdb028689adad4b5f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Grant Likely,

In message <fa686aa40907151017n76524708tdb028689adad4b5f@mail.gmail.com> you wrote:
> On Wed, Jul 15, 2009 at 9:18 AM, Wolfgang Denk<wd@denx.de> wrote:
> > The MII speed calculation was based on the CPU clock (ppc_proc_freq),
> > but for MPC512x we must use the bus clock instead.
> >
> > This patch makes it use the correct clock and makes sure we don't
> > clobber reserved bits in the MII_SPEED register.
...
> Drop the common code bit.  The 5200 and 5121 are different devices and
> it is a tiny bit of code.  I don't think there is any benefit to
> having it as a common function.  Just roll the get_mii_speed function
> in the mii-fec driver itself.

I don't like to see the code repeated - it makes maintenance harder
and increases the memory footprint. But if you like it that way I'll
do that.

> Also, this patch can be quite a bit simpler if you use the .data
> pointer in the drivers match table to specify the function used to
> return the bus clock speed.  Something like this:

OK, will do that, too.

Best regards,

Wolfgang Denk

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
Weekends were made for programming.                 - Karl Lehenbauer
