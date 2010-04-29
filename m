From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/3] [RFC] ptp: IEEE 1588 clock support
Date: Thu, 29 Apr 2010 17:34:02 +0200
Message-ID: <20100429153401.GA26741@riccoc20.at.omicron.at>
References: <20100427091344.GA5086@riccoc20.at.omicron.at> <4BD97573.5050101@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:20612 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933808Ab0D3Umr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 16:42:47 -0400
Received: by fg-out-1718.google.com with SMTP id d23so265930fga.1
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 13:42:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4BD97573.5050101@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 29, 2010 at 02:02:59PM +0200, Wolfgang Grandegger wrote:
> 
> I realized two other netdev drivers already supporting PTP timestamping:
> igb and bfin_mac. From the PTP developer point of view, the interface
> looks rather complete to me and it works fine on my MPC8313 setup.

Do you know whether these two also have PTP clocks? If so, is the API
that I suggested going to work for controlling those clocks, too?

> The only thing I stumbled over was that PTP clock registration
> failed when PTP support is statically linked into the kernel.

Okay, will look into that...

Thanks,
Richard

