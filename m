From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] fec: Unify fec_ptp.c and fec.c
Date: Thu, 21 Mar 2013 10:46:51 +0100
Message-ID: <20130321094650.GA2341@netboy.at.omicron.at>
References: <1363810268-24398-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Frank.Li@freescale.com,
	u.kleine-koenig@pengutronix.de, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:39549 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335Ab3CUJq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 05:46:56 -0400
Received: by mail-ee0-f47.google.com with SMTP id e52so1613730eek.34
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 02:46:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1363810268-24398-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 20, 2013 at 05:11:07PM -0300, Fabio Estevam wrote:

> Move fec_ptp.c code into fec.c and its definitions into fec.h.

...

> +/**
> + * fec_ptp_start_cyclecounter - create the cycle counter from hw
> + * @ndev: network device
> + *
> + * this function initializes the timecounter and cyclecounter
> + * structures for use in generated a ns counter from the arbitrary
> + * fixed point cycles registers in the hardware.
> + */
> +void fec_ptp_start_cyclecounter(struct net_device *ndev)
> +{

This function and the other, previously global functions should now be
changed to 'static'.

Thanks,
Richard
