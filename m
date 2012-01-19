From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] red: Add adaptative algo
Date: Thu, 19 Jan 2012 14:47:11 -0800
Message-ID: <20120119144711.359077d6@nehalam.linuxnetplumber.net>
References: <1323385900.2529.12.camel@edumazet-laptop>
	<20111208164426.03248ca8@nehalam.linuxnetplumber.net>
	<1323403837.2529.14.camel@edumazet-laptop>
	<20111209093309.04b32e27@nehalam.linuxnetplumber.net>
	<1323455459.4016.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50459 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753272Ab2ASWrN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 17:47:13 -0500
In-Reply-To: <1323455459.4016.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 09 Dec 2011 19:30:59 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Enable Adaptative RED algo, using :
> 
> tc qdisc  ... red limit BYTES ... adaptative ...
> 
> Support of high precision probability/max_p setting and reporting, with
> support of old kernels.
> 
> With a new kernel, "Plog ..." is replaced in tc output by "probability
> value" :
> 
> qdisc red 10: dev eth3 parent 1:1 limit 360Kb min 30Kb max 90Kb ecn ewma
> 5 probability 0.09 Scell_log 15
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, but man page also needs update!
