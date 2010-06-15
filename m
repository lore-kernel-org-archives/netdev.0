From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 03/12] phylib: add a driver method for the
 SIOCSHWTSTAMP ioctl.
Date: Tue, 15 Jun 2010 18:34:09 +0200
Message-ID: <20100615163409.GA10668@riccoc20.at.omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
 <77fe18d640e35dcbfad1e117a4321f935500d5ac.1276615626.git.richard.cochran@omicron.at>
 <AANLkTiml5FyHstY-0ZPHxFDvA349BZv3TeX9gXtURFFN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60755 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025Ab0FOQdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 12:33:19 -0400
Received: by fxm10 with SMTP id 10so287079fxm.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 09:33:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTiml5FyHstY-0ZPHxFDvA349BZv3TeX9gXtURFFN@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 10:27:59AM -0600, Grant Likely wrote:
> On Tue, Jun 15, 2010 at 10:08 AM, Richard Cochran
> <richardcochran@gmail.com> wrote:
> > This patch adds a phy driver method for configuring hardware time stamping.
> > Drivers may optionally implement this function.
> >
> > Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> 
> Adding an ioctl to the userspace ABI.  Make sure you cc: linux-kernel
> on the next spin of this series.

Not sure what you mean. SIOCSHWTSTAMP is a standard socket option as
of 2.6.30. The patch just makes it possible for PHY drivers to
implement this option.

Richard

