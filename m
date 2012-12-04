From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 2/4 net-next] tg3: PTP - Implement the ptp api and
 ethtool functions
Date: Tue, 4 Dec 2012 08:53:18 +0100
Message-ID: <20121204075318.GB2261@netboy.at.omicron.at>
References: <1354506171-1646-1-git-send-email-mchan@broadcom.com>
 <1354506171-1646-2-git-send-email-mchan@broadcom.com>
 <20121203185157.GB2531@netboy.at.omicron.at>
 <50BD1F10.7020105@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:52479 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab2LDHxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 02:53:31 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so1481702eaa.19
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2012 23:53:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <50BD1F10.7020105@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 03, 2012 at 01:52:16PM -0800, Nithin Nayak Sujir wrote:
> 
> Yes, the hardware does seem to be different from what you describe
> but I think the conversion is right. I tested this with ptp4l in a
> back-to-back configuration and observed convergence of the master
> offset to ~0. Without this code, the offset keeps increasing.

Okay, thanks, just asking.

It appears that this works just like the IGB. The register value is a
binary fraction of the increment value, and not an addend as I
assumed.

Thanks,
Richard
