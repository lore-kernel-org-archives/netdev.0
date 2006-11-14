From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] cleanup of the sctp state table code
Date: Mon, 13 Nov 2006 16:28:20 -0800
Message-ID: <1163464101.11430.1.camel@w-sridhar2.beaverton.ibm.com>
References: <1163425085.5968.29.camel@twins>
	 <20061113.161833.70217638.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:52194 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S933256AbWKNA2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 19:28:35 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAE0SYcq009192
	for <netdev@vger.kernel.org>; Mon, 13 Nov 2006 19:28:34 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAE0SXak261240
	for <netdev@vger.kernel.org>; Mon, 13 Nov 2006 19:28:33 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAE0SNA0014899
	for <netdev@vger.kernel.org>; Mon, 13 Nov 2006 19:28:23 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061113.161833.70217638.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-11-13 at 16:18 -0800, David Miller wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Mon, 13 Nov 2006 14:38:05 +0100
> 
> > I noticed an insane high density of repeated characters fixable by a
> > simple regular expression:
> > 
> >   % s/{.fn = \([^,]*\),[[:space:]]\+\(\\\n[[:space:]]\+\)\?.name = "\1"}/TYPE_SCTP_FUNC(\1)/g
> > 
> > (NOTE: the .name for .fn = sctp_sf_do_9_2_start_shutdown didn't match)
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> I'll apply this to net-2.6.20, thanks Peter.
> 
> If the SCTP maintainers have some objection, I'll yank it out
> but I can't see why they would :-)

I don't have any objection. The patch looks good.

Acked-by: Sridhar Samudrala <sri@us.ibm.com>

Thanks
Sridhar

