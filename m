From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v1] net/core: support runtime PM on net_device
Date: Thu, 18 Oct 2012 20:55:58 +0800
Message-ID: <CACVXFVMmSFHYU-sNHRM7g_8U6mjbdbE+bNPxM-F8iAB=4WudRA@mail.gmail.com>
References: <1350548469-1267-1-git-send-email-ming.lei@canonical.com>
	<8762689o9u.fsf@nemi.mork.no>
	<CACVXFVPu1m3CJaFavW9eaU3Z850q+x1N_Yo7tri1UTFpgfYVXQ@mail.gmail.com>
	<87obk080us.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Oliver Neukum <oneukum@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-pm@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:56033 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755067Ab2JRM4A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 08:56:00 -0400
In-Reply-To: <87obk080us.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 18, 2012 at 7:40 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
>
> Because bugs are supposed to be fixed and not hidden?

OK, now let's discuss solution for the problem which should be
clear and be solved.

The 1st one is to do it by this patch, or rule out some ioctl cmd
which needn't wakeup device.

The second one is to fix ioctl one by one in each driver.

Any other solution?

>
> Note that I am not claiming this is a bug.  That is still an open
> question as far as I can see.


Thanks,
--
Ming Lei
