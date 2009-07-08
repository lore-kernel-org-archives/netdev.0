From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netpoll: Introduce netpoll_carrier_timeout kernel
 option
Date: Tue, 7 Jul 2009 18:03:54 -0700
Message-ID: <20090707180354.2f203648@nehalam>
References: <20090708010030.GA26331@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52587 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756042AbZGHBEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2009 21:04:01 -0400
In-Reply-To: <20090708010030.GA26331@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Jul 2009 05:00:30 +0400
Anton Vorontsov <avorontsov@ru.mvista.com> wrote:

> Some PHYs require longer timeouts for carrier detection, and
> auto-negotiation process may take indefinite amount of time.
> 
> It may be inconvenient to force longer timeouts for sane PHYs,
> so let's introduce a kernel command line option.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
>  Documentation/kernel-parameters.txt |    5 +++++
>  net/core/netpoll.c                  |   11 ++++++++++-
>  2 files changed, 15 insertions(+), 1 deletions(-)

A sysctl (or module option) is a less awkward interface for something
like this. Kernel command line parameters are ugly step children
loved only by embedded developers.
