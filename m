From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V2 0/7] support the cpts found on am335x devices
Date: Wed, 17 Oct 2012 20:27:15 +0200
Message-ID: <20121017182714.GC2412@netboy.at.omicron.at>
References: <cover.1350329726.git.richardcochran@gmail.com>
 <EB1619762EAF8B4E97A227FB77B7E0293E9F82F0@DBDE01.ent.ti.com>
 <20121016171407.GA2176@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9F86E9@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	"Chemparathy, Cyril" <cyril@ti.com>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37224 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932247Ab2JQS10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 14:27:26 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so1078718wib.1
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 11:27:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293E9F86E9@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 16, 2012 at 11:11:29PM +0000, N, Mugunthan V wrote:
> 
> Yes, I do agree that driver handles it. As Half roll over and Full roll
> over events are not handled in the driver, I am just curious how will
> the misaligned TS would be handled and also in cpts set time, the Lower
> 32 bit time is written to CPTS counter

#include <linux/clocksource.h>

> Since we poll for the 32bit over flow for every HZ * 8 cycle, won't
> there be a system overhead. If the CPTS ref clock is changed according
> to the ptp freq adjust api, how will the timecounter take care of change
> in frequency

There is nothing to do here. What are you asking?

> The current driver which is in vanilla kernel doesn't use extended slave
> address which are conflict between TI814x CPSW IP version and AM335x CPSW
> IP version. I have just posted my version of CPTS implementation. May be
> we can work together make the driver compatible with both CPSW versions

Okay.

> Since CPSW is a 3port Switch we should not fix time stamping will be enabled
> only for slave 0 or passing slave number through DT. Its better if we
> can configure both the slaves. This can be tested with EVM-sk which has
> both the slave ports pinned out.

I hope that you meant, "better if we can configure _either_ slave."
Considering how SO_TIMESTAMPING works, you can't use both at once.

Thanks,
Richard
