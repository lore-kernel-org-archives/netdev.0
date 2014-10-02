From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] net: ethernet: Remove superfluous ether_setup after
 alloc_etherdev
Date: Thu, 2 Oct 2014 10:20:16 +0200
Message-ID: <20141002082016.GJ3279@distanz.ch>
References: <1412237730-5811-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>,
	Vince Bridgers <vbridgers2013@gmail.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Nicolas Pitre <nico@fluxnic.net>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:47232 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180AbaJBIUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 04:20:19 -0400
Content-Disposition: inline
In-Reply-To: <1412237730-5811-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-10-02 at 10:15:30 +0200, Tobias Klauser <tklauser@distanz.ch> wrote:
> There is no need to call ether_setup after alloc_ethdev since it was
> already called there.
> 
> Follow commits c706471b2601 ("net: axienet: remove unnecessary
> ether_setup after alloc_etherdev") and 3c87dcbfb36c ("net: ll_temac:
> Remove unnecessary ether_setup after alloc_etherdev") and fix the
> pattern in all remaining ethernet drivers.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

This patch is for net-next. Sorry for not mentioning this in the subject
right away.
