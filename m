From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/5] y2038 conversion for ntp/pps and sfc driver
Date: Tue, 29 Sep 2015 21:17:50 +0200
Message-ID: <20150929191750.GA21910@localhost.localdomain>
References: <1443471692-2946597-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: y2038@lists.linaro.org, Thomas Gleixner <tglx@linutronix.de>,
	John Stultz <john.stultz@linaro.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Rodolfo Giometti <giometti@enneenne.com>,
	linux-net-drivers@solarflare.com,
	Shradha Shah <sshah@solarflare.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37573 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583AbbI2TR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 15:17:56 -0400
Content-Disposition: inline
In-Reply-To: <1443471692-2946597-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 28, 2015 at 10:21:27PM +0200, Arnd Bergmann wrote:
> When trying to build a kernel with time_t commented out, I found that
> the ntp subsystem still relies on timespec for its pps handling.
> 
> This series addresses this and converts all the code to use timespec64
> instead, step by step. There is one device driver that interacts with
> this code directly (rather than only through the ptp subsystem), so
> I have to convert that driver at the same time.
> 
> The patches should ideally stay together as a series, but they do
> span multiple subsystems, so I'm also looking for the right person
> to merge them.
> 
> Please review.

(Series was "lightly reviewed" ;)

Acked-by: Richard Cochran <richardcochran@gmail.com>
