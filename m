From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 11/12] ptp: Added a clock driver for the IXP46x.
Date: Wed, 16 Jun 2010 08:54:35 +0200
Message-ID: <20100616065435.GE2887@riccoc20.at.omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
 <0c03ef3e283c6b3ef58feaf1f77ccb0fd605010b.1276615626.git.richard.cochran@omicron.at>
 <AANLkTinPDaWNvUG8q8RdvRUga-qrPlSV2H5TkzVVMaFn@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43735 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754319Ab0FPGxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 02:53:45 -0400
Received: by fxm10 with SMTP id 10so525210fxm.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 23:53:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTinPDaWNvUG8q8RdvRUga-qrPlSV2H5TkzVVMaFn@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 12:41:56PM -0600, Grant Likely wrote:
> Nitpick.  We use all lower case names for structures in Linux.

Yes, I know, but in this case an exception makes sense.

I prefer to use the exact same register mnemonics as in the hardware
documentation, whenever possible. That way, anyone later working on
the driver with hardware manual in hand (and they should be doing that
way) will immediately see the connection.

> You want to get stuff as fast as possible, but there is a udelay()
> that just chews up CPU time.  Would cpu_relax() be sufficient with a
> time-based exit condition in the loop?

I am not sure. What does cpu_relax() do exactly, and when is it safe
to call?

Thanks,
Richard
