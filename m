From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute uses too small of a receive buffer
Date: Tue, 10 Nov 2009 09:15:03 -0800
Message-ID: <20091110091503.2fb57d55@nehalam>
References: <4AE77F64.3090302@candelatech.com>
	<20091027162434.6dc31b2d@nehalam>
	<4AE7F859.7020105@gmail.com>
	<4AE895E8.60308@trash.net>
	<4AE89927.9090405@candelatech.com>
	<4AE8A098.8040207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	NetDev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49196 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757306AbZKJRP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 12:15:29 -0500
In-Reply-To: <4AE8A098.8040207@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> How about this? It uses 1MB as receive buf limit by default (without
> increasing /proc/sys/net/core/rmem_max it will be limited by less
> however) and allows to specify the size manually using "-rcvbuf X"
> (-r is already used, so you need to specify at least -rc).
> 
> Additionally rtnl_listen() continues on ENOBUFS after printing the
> error message.

Applied, seems like the best workaround
