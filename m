From: Jamie Gloudon <jamie.gloudon@gmail.com>
Subject: Re: [BUG] via-rhine: NOHZ: local_softirq_pending 08
Date: Wed, 23 Jan 2013 21:04:37 -0400
Message-ID: <510088ac.8481ec0a.1edd.1266@mx.google.com>
References: <51007b84.03ab640a.1cde.fffff62a@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f176.google.com ([209.85.160.176]:54393 "EHLO
	mail-gh0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455Ab3AXBEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 20:04:45 -0500
Received: by mail-gh0-f176.google.com with SMTP id f16so360863ghb.7
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 17:04:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <51007b84.03ab640a.1cde.fffff62a@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 08:08:29PM -0400, Jamie Gloudon wrote:
> Hey,
> 
>    While conducting some tests on a VT6105M card. I noticed this message:
> 
> kernel: [  160.311113] NOHZ: local_softirq_pending 08
> 
> I was able to reliably reproduce the error message by setting autoneg off and changing the interface speed from 100 to 10 with ethtool.
> 
> Regards,
> Jamie Gloudon

I forget to mention this error message occur on stable 3.7.
