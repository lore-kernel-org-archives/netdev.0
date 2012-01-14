From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3 1/2] gianfar: Fix missing sock reference when
 processing TX time stamps
Date: Sat, 14 Jan 2012 18:17:10 +0100
Message-ID: <20120114171709.GA2183@netboy.at.omicron.at>
References: <1326187612-27384-1-git-send-email-manfred.rudigier@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	afleming@freescale.com, avorontsov@mvista.com,
	eric.dumazet@gmail.com
To: Manfred Rudigier <manfred.rudigier@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40386 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755699Ab2ANRRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 12:17:24 -0500
Received: by eaal12 with SMTP id l12so535787eaa.19
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2012 09:17:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1326187612-27384-1-git-send-email-manfred.rudigier@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2012 at 10:26:50AM +0100, Manfred Rudigier wrote:
> When there is not enough headroom in the skb a private copy will be made.
> However, the private copy had no reference to the socket and consequently
> no time stamp could be queued on the socket error queue during the
> skb_tstamp_tx function. This patch fixes this issue by also stealing the
> sock reference from the original skb after making the private copy.

Hi Manfred,

If you feel like helping with maintainance, these two fixes should
also go into stable. Once they have appeared in mainline, you can send
them to the stable list, mentioning the upstream commit ID.

[ If you put the Cc: tag in the sign off area, then the stable
  submission occurs automatically. Sorry, I probably should have
  explained that before. ]

Thanks,
Richard
