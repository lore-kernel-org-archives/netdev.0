From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Check if user has CAP_NET_ADMIN to change congestion
 control algorithm
Date: Thu, 26 Oct 2006 18:03:29 -0700
Message-ID: <20061026180329.571de4c8@localhost.localdomain>
References: <20061025110843.0cbd18a7@freekitty>
	<4540F076.70801@psc.edu>
	<20061026224407.GA2018@c3po.0xdef.net>
	<20061026235256.GB2018@c3po.0xdef.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	John Heffner <jheffner@psc.edu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:6368 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946067AbWJ0BDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 21:03:55 -0400
To: Hagen Paul Pfeifer <hagen@jauu.net>
In-Reply-To: <20061026235256.GB2018@c3po.0xdef.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Oct 2006 01:52:56 +0200
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> 
> Check if user has CAP_NET_ADMIN capability to change congestion control
> algorithm.
> 
> Under normal circumstances a application programmer doesn't have enough
> information to choose the "right" algorithm (expect he is the pchar/pathchar
> maintainer). At 99.9% only the local host administrator has the knowledge to
> select a proper standard, system-wide algorithm (the remaining 0.1% are
> for testing purpose). If we let the user select an alternative algorithm we
> introduce one potential weak spot - so we ban this eventuality.
> 
> HGN

If you aren't doing experiments don't compile it in your kernel.
If distro's are including "unfair" congestion control file a bug report.
