From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/3] ptp: Added a brand new class driver for ptp clocks.
Date: Mon, 3 May 2010 12:07:54 +0200
Message-ID: <20100503100754.GA30417@riccoc20.at.omicron.at>
References: <20100429091936.GA6703@riccoc20.at.omicron.at>
 <4BDD5910.1040604@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:34934 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346Ab0ECKHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 06:07:55 -0400
Received: by fg-out-1718.google.com with SMTP id d23so977087fga.1
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 03:07:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4BDD5910.1040604@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 02, 2010 at 12:50:56PM +0200, Wolfgang Grandegger wrote:
> 
> As long as the device is in use by an application, no other can access
> it, because the mutex is locked. Other application may want to read the
> PTP clock time while ptpd is running, though.

Yes, of course. I implemented it that way just to get started. I first
want to concentrate on getting the basic drivers in place (still have
IXP46x and Phyter to do), and then on the ancillary features, like
timers, time stamping external inputs, and so on.

I understand that some fine grained access control to the PTP clock
woul be nice to have, but I am not sure exactly what would work best,
and I would like to save that decision for later...

However, if you have some ideas, please take a look at the list of
features in the docu, and explain how you would like the access
control to work.

Or better yet, post a patch ;)

Thanks,
Richard
