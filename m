From: Wolfgang Denk <wd@denx.de>
Subject: Re: [PATCH 2/2] MPC52xx FEC: be more conservative when setting MII_SPEED register
Date: Thu, 16 Jul 2009 23:21:50 +0200
Message-ID: <20090716212150.B0DF0832E416@gemini.denx.de>
References: <1247578966-9847-1-git-send-email-wd@denx.de> <1247671133-12148-2-git-send-email-wd@denx.de> <fa686aa40907151018n194a154cmb8549c98c673d2bb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linuxppc-dev@ozlabs.org, Kumar Gala <galak@kernel.crashing.org>,
	netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:39044 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933403AbZGPVVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 17:21:52 -0400
In-reply-to: <fa686aa40907151018n194a154cmb8549c98c673d2bb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Grant Likely,

In message <fa686aa40907151018n194a154cmb8549c98c673d2bb@mail.gmail.com> you wrote:
> On Wed, Jul 15, 2009 at 9:18 AM, Wolfgang Denk<wd@denx.de> wrote:
> > This patch adds error checking and prevents clobbering unrelated bits
> > (reserved bits or the DIS_PREAMBLE bit) when writing the MII_SPEED
> > register on MPC52xx systems.
...
> As I mentioned in the other patch, I don't want the 5121 and 5200 FEC
> devices using common code for this.  It is a tiny block of code and
> they are different devices.  Just open code the needed calculation
> into this driver.

OK, will do.
