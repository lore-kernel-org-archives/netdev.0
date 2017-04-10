From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: make sure no NULL pointer is passed through
Date: Mon, 10 Apr 2017 11:01:02 +0200
Message-ID: <1491814862.1496.1.camel@suse.com>
References: <20170405121439.22523-1-oneukum@suse.com>
         <20170406.131907.1888296039502840628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: bjorn@mork.no, stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45977 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750989AbdDJJCI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 05:02:08 -0400
In-Reply-To: <20170406.131907.1888296039502840628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, den 06.04.2017, 13:19 -0700 schrieb David Miller:
> From: Oliver Neukum <oneukum@suse.com>
> Date: Wed,  5 Apr 2017 14:14:39 +0200
> 
> > Coverity reports:
>  ...
> > It is valid to offer commands without a buffer, but then you need a size
> > of zero. This should actually be checked.
> > 
> > Signed-off-by: Oliver Neukum <oneukum@suse.com>
> 
> Applied, thanks Oliver.
> 
> I had to apply this by hand via my inbox rather than using patchwork
> because those coverity report delimiters cause patchwork to chop off
> most of your commit message.
> 

Hi,

thanks. That is not good. It seems to me that a Coverity report
should be in the change log. Do you have suggestions how to do
this in a friendly manner?

	Regards
		Oliver
