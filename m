From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC][PATCH 0/3] net_tstamp: Add SIOCGHWTSTAMP ioctl
Date: Thu, 14 Nov 2013 08:41:19 +0100
Message-ID: <20131114074118.GC4908@netboy>
References: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:47528 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132Ab3KNHlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 02:41:31 -0500
Received: by mail-wg0-f46.google.com with SMTP id x12so1448944wgg.1
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 23:41:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 02:37:15AM +0000, Ben Hutchings wrote:
> SIOCSHWTSTAMP returns the real configuration to the application
> using it, but there is currently no way for any other
> application to find out the configuration non-destructively.

I guess that the reasoning behind the original interface is that an
application only wants to know the settings when it needs a particular
setting in order to operate correctly. This would make the query call
pointless, since the application might as well just go ahead and set
the values that it needs.

Do you have a particular use case in mind?

Thanks,
Richard
