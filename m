From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] e1000e: Change wthresh to 1 to avoid possible Tx
 stalls.
Date: Thu, 07 Jun 2012 06:24:45 +0200
Message-ID: <1339043085.26966.77.camel@edumazet-glaptop>
References: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>
	 <1339030752.2075.1.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"denys@visp.net.lb" <denys@visp.net.lb>,
	"therbert@google.com" <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:43110 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933585Ab2FGEYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 00:24:51 -0400
Received: by eaak11 with SMTP id k11so45582eaa.19
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 21:24:49 -0700 (PDT)
In-Reply-To: <1339030752.2075.1.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 17:59 -0700, Jeff Kirsher wrote:

> After further internal review, NACK.
> 
> This patch will cause unacceptable performance issues with non-ESB2
> parts.
> 
> I am dropping this patch from my queue.
> 

I'd like you share your performance numbers before NACKing this patch.

What is the alternative patch you guys have ?
