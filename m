From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: increase receive packet quantum
Date: Mon, 3 Nov 2008 21:25:21 -0800
Message-ID: <20081103212521.15e12168@extreme>
References: <20081103130303.29dd4e21@extreme>
	<20081103.172428.154364341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33194 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141AbYKDFZY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 00:25:24 -0500
In-Reply-To: <20081103.172428.154364341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 Nov 2008 17:24:28 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 3 Nov 2008 13:03:03 -0800
> 
> > This patch gets about 1.25% back on tbench regression.
> > 
> > My change to NAPI for multiqueue support changed the time limit on
> > network receive processing.  Under sustained loads like tbench, this
> > can cause the receiver to reschedule prematurely. 
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> I think I'm the guilty party that made that change to your
> NAPI patches.
> 
> I'll apply this to net-next-2.6, thanks Stephen.

Maybe you want it as part of the tbench regression recovery in 2.6.28?
it seems mostly harmless.
