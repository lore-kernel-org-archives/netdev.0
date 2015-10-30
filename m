From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [1/1] stmmac: Correctly report PTP capabilities.
Date: Fri, 30 Oct 2015 11:22:00 +0100
Message-ID: <20151030102200.GA4771@localhost.localdomain>
References: <1446194635-19782-1-git-send-email-preid@electromag.com.au>
 <1446194635-19782-2-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: Phil Reid <preid@electromag.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38584 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756952AbbJ3KWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 06:22:05 -0400
Received: by wmeg8 with SMTP id g8so8219796wme.1
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 03:22:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1446194635-19782-2-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2015 at 04:43:55PM +0800, Phil Reid wrote:
> priv->hwts_*_en indicate if timestamping is enabled/disabled at run
> time. But  priv->dma_cap.time_stamp  and priv->dma_cap.atime_stamp
> indicates HW is support for PTPv1/PTPv2.
> 
> Signed-off-by: Phil Reid <preid@electromag.com.au>

Thanks for catching this bug.

Acked-by: Richard Cochran <richardcochran@gmail.com>
