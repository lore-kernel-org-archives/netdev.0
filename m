From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] tbf scheduler: TSO support
Date: Thu, 10 May 2007 18:01:41 +0200
Message-ID: <464341E5.50300@trash.net>
References: <20070511.010030.06784245.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hirokazu Takahashi <taka@valinux.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39173 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756704AbXEJQC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 12:02:28 -0400
In-Reply-To: <20070511.010030.06784245.taka@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hirokazu Takahashi wrote:
> TBF --- Simple Token Bucket Filter --- packet scheduler doesn't
> work correctly with TSO on that it slows down to send out packets.
> TSO packets will be discarded since the size can be larger than
> the scheduler expects. But it won't cause serious problems
> because the retransmitted packets can be passed.


I already CCed netdev in my reply, so please use that thread instead
of starting a new one.
