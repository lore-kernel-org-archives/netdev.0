From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 13 Jan 2010 22:34:36 +0100
Message-ID: <20100113213435.GB3065@del.dom.local>
References: <20100108074539.GA6205@ff.dom.local>
 <4B475FF9.7000702@majjas.com>
 <20100108212923.GA3078@del.dom.local>
 <4B47A81B.5040601@majjas.com>
 <4B4809EF.1070609@majjas.com>
 <20100109122830.GA4386@del.dom.local>
 <4B48CC2C.2090403@majjas.com>
 <4B4E2F89.2050606@majjas.com>
 <20100113210908.GA3065@del.dom.local>
 <4B4E3834.3000609@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:43902 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652Ab0AMVeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 16:34:44 -0500
Content-Disposition: inline
In-Reply-To: <4B4E3834.3000609@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 13, 2010 at 04:16:36PM -0500, Michael Breuer wrote:
> If it helps, I'm still getting one error without DMAR enabled - at
> startup, there's a DMA sync oops - mismatch of 72 bytes coming from
> sky2. That oops was posted previously - with DMAR (re) enabled,
> there's no related oops.

I hope re-posting this oops with this information should be helpful.

Jarek P.
