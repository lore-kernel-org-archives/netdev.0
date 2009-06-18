From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/9] sky2: fix shutdown synchronization
Date: Thu, 18 Jun 2009 16:41:05 -0700
Message-ID: <20090618164105.6f17481e@nehalam>
References: <20090617173031.703636683@vyatta.com>
	<20090617173139.828049268@vyatta.com>
	<4A3ACCCF.1080605@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51070 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751502AbZFRXlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2009 19:41:08 -0400
In-Reply-To: <4A3ACCCF.1080605@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Jun 2009 08:25:03 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> 
> Hi Steven,
> 
> After applying your complete patch series, I'm still getting crashes in 
> sky2_poll, and I can make them go away by adding an msleep(1) before 
> these lines in sky2_down.
> 

adding msleep adds delay so interrupt and packets can clear, that is okay,
but would rather have something deterministic?  perhaps it needs to poll
irq status register or napi status.

-- 
