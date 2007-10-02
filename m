From: Robert Schwebel <r.schwebel@pengutronix.de>
Subject: Re: [RFC PATCH v0.2] net driver: mpc52xx fec
Date: Tue, 2 Oct 2007 17:46:02 +0200
Message-ID: <20071002154602.GV23573@pengutronix.de>
References: <20070810095153.GC13994@moe.telargo.com> <20070902074143.GB2642@nd47.coderock.org> <20071002124939.GC10481@pengutronix.de> <20071002143202.GQ32628@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Sascha Hauer <s.hauer@pengutronix.de>, netdev@vger.kernel.org,
	linuxppc-embedded@ozlabs.org
To: Domen Puncer <domen@coderock.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.extern.pengutronix.de ([83.236.181.26]:45786 "EHLO
	metis.extern.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751671AbXJBPqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 11:46:15 -0400
Content-Disposition: inline
In-Reply-To: <20071002143202.GQ32628@nd47.coderock.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 04:32:02PM +0200, Domen Puncer wrote:
> The patch looks ok to me.

Short update: even with the patch, the driver doesn't work on an
rt-preempt enabled kernel, or at least not reliable. It survives normal
traffic and ping -f, but dies when running nmap against the box, with a
set RFIFO_ERROR flag.

More research needs to be done.

Robert
-- 
Pengutronix - Linux Solutions for Science and Industry
Entwicklungszentrum Nord     http://www.pengutronix.de
