From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] net/enc28j60: low power mode
Date: Wed, 5 Mar 2008 15:31:16 -0800
Message-ID: <200803051531.16334.david-b@pacbell.net>
References: <47B415D3.6020200@eptar.com> <47CE806B.9010102@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Claudio Lanconelli <lanconelli.claudio@eptar.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp118.sbc.mail.sp1.yahoo.com ([69.147.64.91]:21559 "HELO
	smtp118.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753729AbYCEXbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 18:31:18 -0500
In-Reply-To: <47CE806B.9010102@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 March 2008, Jeff Garzik wrote:
> Claudio Lanconelli wrote:
> > Keep enc28j60 chips in low-power mode when they're not in use.
> > At typically 120 mA, these chips run hot even when idle; this
> > low power mode cuts that power usage by a factor of around 100.
> > 
> > This version provides a generic routine to poll a register until
> > its masked value equals some value ...
> 
> It's a bit silly to create a variable just to store the result of 
> msecs_to_jiffies(constant)

Sillier to replace a compile-time constant with a runtime function
call!  The msecs_to_jiffies() implementation doesn't optimize the
case of a constant parameter -- there's no inlined version.




