From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 04/04] smc91x: add insw/outsw to default config
Date: Wed, 20 Feb 2008 11:00:44 -0500 (EST)
Message-ID: <alpine.LFD.1.00.0802201059080.2732@xanadu.home>
References: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
 <20080220095821.22645.60604.sendpatchset@clockwork.opensource.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	akpm@linux-foundation.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:59750 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbYBTQAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 11:00:45 -0500
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR003.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0JWJ00341OH9I190@VL-MO-MR003.ip.videotron.ca> for
 netdev@vger.kernel.org; Wed, 20 Feb 2008 11:00:45 -0500 (EST)
In-reply-to: <20080220095821.22645.60604.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2008, Magnus Damm wrote:

> This patch makes sure SMC_insw()/SMC_outsw() are defined for the
> default configuration. Without this change BUG()s will be triggered
> when using 16-bit only platform data and the default configuration.
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>

You should have introduced this patch as 3/4 instead of 4/4 so to make 
sure the series won't  create a non functional kernel between 3/4 and 
4/4.


Nicolas
