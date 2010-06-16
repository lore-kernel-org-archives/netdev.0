From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 04/12] phylib: add a way to make PHY time stamps
 possible.
Date: Wed, 16 Jun 2010 07:40:47 +0200
Message-ID: <20100616054047.GA2887@riccoc20.at.omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
 <27c0ad283f025c2bb71e7ceb71be07f969939429.1276615626.git.richard.cochran@omicron.at>
 <AANLkTimhAvu0_WuMCwnCrw9Rbcy6dKxvTlzepJm7ZDdR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:43735 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754139Ab0FPFj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 01:39:57 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1400038fga.1
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 22:39:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTimhAvu0_WuMCwnCrw9Rbcy6dKxvTlzepJm7ZDdR@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 10:33:51AM -0600, Grant Likely wrote:
> > +config NETWORK_PHY_TIMESTAMPING
> Some overhead?  At a brief glance of the series it looks like it could
> add a lot of overhead, but I'm not fully clear on what the full
> process is.  Can you describe how the hardware timestamping works?  I
> could use an overview of what the kernel has to do.

First of all, I want to emphasize that this network stack option is
purely voluntary. Only those people who know that they have a PTP
capable PHY and really want the timestamps will (or should) enable
this option. When it is not enabled, it has no effect at all.

Hardware timestamping is described in

   Documentation/networking/timestamping.txt
   Documentation/networking/timestamping/timestamping.c

The PTP subsystem is described in

   Documentation/ptp/ptp.txt

There really is more to say about the issue than appears in those
documents, but they are a good starting place for discussion.

BTW I am submitting a conference paper on the design on the PTP
subsystem. If you would like to have it, just ask me off-list.

Richard
