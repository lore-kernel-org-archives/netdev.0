From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH]  remove isa stuff from smc91x driver
Date: Wed, 3 Dec 2008 14:52:35 +0000
Message-ID: <20081203145235.05e1f461@lxorguk.ukuu.org.uk>
References: <1228315701-17240-1-git-send-email-l.fu@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Luotao Fu <lfu@pengutronix.de>
To: Luotao Fu <l.fu@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:60713 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751264AbYLCOw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 09:52:27 -0500
In-Reply-To: <1228315701-17240-1-git-send-email-l.fu@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  3 Dec 2008 15:48:21 +0100
Luotao Fu <l.fu@pengutronix.de> wrote:

> From: Luotao Fu <lfu@pengutronix.de>
> 
> ISA support in smc91x is incomplete. I doubt there're any smc91x isa card.
> This driver is greatly used on arm pxa platforms. Hence we remove the
> isa stuff from smc91x driver.

This makes no sense. It is protected by an ifdef anyway so doesn't affect
ARM

