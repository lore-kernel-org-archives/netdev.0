From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: make sure no NULL pointer is passed through
Date: Thu, 06 Apr 2017 13:19:07 -0700 (PDT)
Message-ID: <20170406.131907.1888296039502840628.davem@davemloft.net>
References: <20170405121439.22523-1-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org, bjorn@mork.no
To: oneukum@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37632 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752173AbdDFUTL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 16:19:11 -0400
In-Reply-To: <20170405121439.22523-1-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.com>
Date: Wed,  5 Apr 2017 14:14:39 +0200

> Coverity reports:
 ...
> It is valid to offer commands without a buffer, but then you need a size
> of zero. This should actually be checked.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.com>

Applied, thanks Oliver.

I had to apply this by hand via my inbox rather than using patchwork
because those coverity report delimiters cause patchwork to chop off
most of your commit message.

Just FYI...
