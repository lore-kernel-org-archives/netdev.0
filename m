From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] net-timestamp: document deprecated syststamp
Date: Tue, 15 Jul 2014 08:31:01 +0200
Message-ID: <20140715063101.GB4087@localhost.localdomain>
References: <1405374930-4763-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37391 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757766AbaGOGbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 02:31:23 -0400
Received: by mail-wi0-f172.google.com with SMTP id n3so3700652wiv.11
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 23:31:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405374930-4763-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2014 at 05:55:30PM -0400, Willem de Bruijn wrote:
> The SO_TIMESTAMPING API defines option SOF_TIMESTAMPING_SYS_HW.
> This feature is deprecated. It should not be implemented by new
> device drivers. Existing drivers do not implement it, either --
> with one exception.
> 
> Driver developers are encouraged to expose the NIC hw clock as a
> PTP HW clock source, instead, and synchronize system time to the
> HW source.
> 
> The control flag cannot be removed due to being part of the ABI, nor
> can the structure scm_timestamping that is returned. Due to the one
> legacy driver, the internal datapath and structure are not removed.
> 
> This patch only clearly marks the interface as deprecated. Device
> drivers should always return a syststamp value of zero.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Thanks a bunch for this!

Acked-by: Richard Cochran <richardcochran@gmail.com>
