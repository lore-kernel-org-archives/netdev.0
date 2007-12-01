From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change (resend)
Date: Sat, 01 Dec 2007 16:36:12 -0500
Message-ID: <4751D3CC.7020607@pobox.com>
References: <20071114193844.0cab5c7d@freepuppy.rosehill>	<20071115082600.GA2366@ff.dom.local>	<20071115102005.0cf46f9a@freepuppy.rosehill>	<473CD1F6.9030709@o2.pl>	<cccedfc60711151842l4aafe0ffo220e84a5e37b6a82@mail.gmail.com>	<20071115203508.4ad025f2@freepuppy.rosehill>	<cccedfc60711281402m397a37d2mda83645211633202@mail.gmail.com> <20071128142016.0eecbd2c@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jon Nelson <jnelson@jamponi.net>, Jarek Poplawski <jarkao2@o2.pl>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32944 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751167AbXLAVgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:36:23 -0500
In-Reply-To: <20071128142016.0eecbd2c@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> The VIA veloicty driver needs the following to allow changing MTU when down.
> The buffer size needs to be computed when device is brought up, not when
> device is initialized.  This also fixes a bug where the buffer size was
> computed differently on change_mtu versus initial setting.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
> This is a properly formatted version of previously submitted patch.
> Please apply for 2.6.24

applied


