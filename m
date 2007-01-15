From: Jens Stroebel <drifter@bcsoft.de>
Subject: Re: network failures w. r8169 (RTL8111/RTL8168B)
Date: Mon, 15 Jan 2007 16:28:43 +0100
Message-ID: <20070115152843.GB2666@lida5.home.bcs>
References: <20070115143857.GA2666@lida5.home.bcs>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:52332 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbXAOP2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 10:28:54 -0500
Received: from lida5.home.bcs (unknown [192.168.142.55])
	by lunaslave.outerlounge.de (Postfix) with ESMTP id 7D6522556E
	for <netdev@vger.kernel.org>; Mon, 15 Jan 2007 16:28:51 +0100 (CET)
Received: from lida5.home.bcs (localhost [127.0.0.1])
	by lida5.home.bcs (8.13.6/8.13.6) with ESMTP id l0FFShT1012132
	for <netdev@vger.kernel.org>; Mon, 15 Jan 2007 16:28:43 +0100
Received: (from drifter@localhost)
	by lida5.home.bcs (8.13.6/8.13.6/Submit) id l0FFShxP012131
	for netdev@vger.kernel.org; Mon, 15 Jan 2007 16:28:43 +0100
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070115143857.GA2666@lida5.home.bcs>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 15, 2007 at 03:38:57PM +0100, Jens Stroebel wrote:

> During the use of network connections, we experience "network transfer
> stops" during which a transfer seems to stall completely for many
> seconds, after which the transfer runs as if nothing happened.
> 

Addition:

Trying to debug the scenario a little, I used tcpdump to maybe find out
what/where things get lost.

This didn't work, as running tcpdump on !either server or client! made
the symtom go away (..?)

		Greets,
		  Jens
-- 
drifter@bcsoft.de
			23.....56.......drifting 
