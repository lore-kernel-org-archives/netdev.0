From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 0/4] PTP attribute handling cleanup
Date: Thu, 16 Feb 2017 21:19:29 +0100
Message-ID: <20170216201928.GA8614@netboy>
References: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35554 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932740AbdBPUTf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 15:19:35 -0500
Content-Disposition: inline
In-Reply-To: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2017 at 10:23:30AM -0800, Dmitry Torokhov wrote:
>  drivers/ptp/ptp_clock.c   |  22 +++---
>  drivers/ptp/ptp_private.h |   7 +-
>  drivers/ptp/ptp_sysfs.c   | 167 ++++++++++++++++++----------------------------
>  3 files changed, 80 insertions(+), 116 deletions(-)

Nice reduction in sysfs code!

I gave this some light testing on the coldfire/phyter (which has 12
pins), and nothing exploded.

For the series:

Acked-by: Richard Cochran <richardcochran@gmail.com>
