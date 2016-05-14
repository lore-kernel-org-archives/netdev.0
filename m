From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: What ixgbe devices support HWTSTAMP_FILTER_ALL for hardware time
 stamping?
Date: Sat, 14 May 2016 22:26:53 +0200
Message-ID: <20160514202653.GA6529@netboy>
References: <582A121C-339D-4469-958C-9673C7E5A654@alum.mit.edu>
 <20160514073002.GA2053@netboy>
 <4AAA3CE1-B137-4AC1-AB85-B4690E8E3E12@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37944 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753905AbcENU07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 16:26:59 -0400
Received: by mail-wm0-f41.google.com with SMTP id g17so78937895wme.1
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 13:26:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AAA3CE1-B137-4AC1-AB85-B4690E8E3E12@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2016 at 11:47:22AM -0700, Guy Harris wrote:
> So if you have a GUI application for packet capture, with a combo box to select the type of time stamping, should it:
> 
> 	1) regardless of whether ETHTOOL_GET_TS_INFO is available, open the adapter, try each of the time stamp types to see whether it works, and show a combo box based on that;
> 
> 	2) use ETHTOOL_GET_TS_INFO if available;
> 
> 	3) offer all possibilities regardless of whether they work with the adapter or not, and just report an error for possibilities that don't work?
> 
> My preference is 2) - which is the main reason why libpcap offers "what possibilities are available?" APIs, not just "request this possibility" APIs.

You are going to have to implement #1 in any case, if you want your
program to work on all kernels.  IIRC get_ts_info appeared in 3.5.

Thanks,
Richard
