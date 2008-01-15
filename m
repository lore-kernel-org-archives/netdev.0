From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: questions on NAPI processing latency and dropped network	packets
Date: Tue, 15 Jan 2008 08:47:07 -0600
Message-ID: <478CC76B.1020804@nortel.com>
References: <20080115071950.GA1696@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:56488 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbYAOOrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 09:47:36 -0500
In-Reply-To: <20080115071950.GA1696@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:

> IMHO, checking this with a current stable, which probably you are going
> to do some day, anyway, should be 100% acceptable: giving some input to
> netdev, while still working for yourself.

While I would love to do this, it's not that simple.

Some of our hardware is not supported on mainline, so we need per-kernel 
version patches to even bring up the blade.  The blades netboot via a 
jumbo-frame network, so kernel extensions are needed to handle setting 
the MTU before mounting the rootfs.  The blade in question uses CKRM 
which doesn't exist for newer kernels so the problem may simply be 
hidden by scheduling differences.  The userspace application uses other 
kernel features that are not in mainline (and likely some of them won't 
ever be in mainline--I know because I've tried).

Basically, the number of changes required for our environment makes it 
difficult to just boot up the latest kernel.

Chris
