From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 4/5] ntp/pps: use y2038 safe types in pps_event_time
Date: Wed, 30 Sep 2015 09:25:39 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1509300925280.4500@nanos>
References: <1443471692-2946597-1-git-send-email-arnd@arndb.de> <1443471692-2946597-5-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: y2038@lists.linaro.org, John Stultz <john.stultz@linaro.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rodolfo Giometti <giometti@enneenne.com>,
	linux-net-drivers@solarflare.com,
	Shradha Shah <sshah@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:56922 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754279AbbI3H0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 03:26:18 -0400
In-Reply-To: <1443471692-2946597-5-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Sep 2015, Arnd Bergmann wrote:

> The pps_event_time uses two 'timespec' structures internally, which
> suffer from the y2038 problem. The uses of this structure are
> fairly self-contained in the pps code, so this replaces them all at
> once.
> 
> Unfortunately, this includes the sfc ethernet driver aside from the
> pps subsystem, so we change that one as well. Both touch the
> same data structure, and there probably is no good way to split
> the patch into smaller units.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
