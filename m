From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v1 4/4] ARM: Documentation: Update fec dts binding doc
Date: Wed, 1 Oct 2014 05:59:00 +0200
Message-ID: <20141001035900.GA4544@netboy>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
 <1411632621-17429-5-git-send-email-b45643@freescale.com>
 <20140925144350.GC21453@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, shawn.guo@linaro.org,
	bhutchings@solarflare.com, R49496@freescale.com,
	b38611@freescale.com, b20596@freescale.com,
	stephen@networkplumber.org
To: Luwei Zhou <b45643@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:47463 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbaJAD7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 23:59:07 -0400
Received: by mail-wi0-f177.google.com with SMTP id ho1so101773wib.4
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 20:59:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140925144350.GC21453@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2014 at 04:43:50PM +0200, Richard Cochran wrote:
> On Thu, Sep 25, 2014 at 04:10:21PM +0800, Luwei Zhou wrote:
> > This patch update fec devicetree binding doc that add Optional properties
> > "pps-channel".
> 
> Again, use the PTP pin interface. We don't need a random new FEC DT
> property for this.

BTW, if the "channel" only means an internal timer resource, please
find a proper way to claim that resource. Do not add another random DT
property. We have enough of those already.
 
Thanks,
Richard
