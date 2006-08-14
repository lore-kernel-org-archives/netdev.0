From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] Remove ugly TODO output from log files in bcm43xx-softmac
Date: Mon, 14 Aug 2006 14:55:02 -0400
Message-ID: <20060814185456.GB13934@tuxdriver.com>
References: <44DA4FF5.4020507@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:62481 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932310AbWHNSzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 14:55:48 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <44DA4FF5.4020507@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 04:13:25PM -0500, Larry Finger wrote:
> This patch removes the ugly TODO output from the logs for bcm43xx-softmac. 
> The
> patch is for the latest version of Linville's wireless-2.6 tree.

I'm not sure if this is the right approach.  In fact I know it isn't --
the right approach would be to implement the missing code! :-)

But barring that, wouldn't it be better to change the TODO() macro
to key off a build-time definition like CONFIG_BCM43XX_DEBUG?

Michael, what do you think?

John
-- 
John W. Linville
linville@tuxdriver.com
