From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/6] sky2: update
Date: Fri, 14 May 2010 08:19:57 -0700
Message-ID: <20100514081957.00f342d5@nehalam>
References: <20100513161247.833356588@vyatta.com>
	<20100514.031501.57481177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mikem@ring3k.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40446 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752544Ab0ENPT7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 11:19:59 -0400
In-Reply-To: <20100514.031501.57481177.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 May 2010 03:15:01 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 13 May 2010 09:12:47 -0700
> 
> > Bunch of patches from Mike, with some additional comments.
> 
> All applied to net-next-2.6, thanks.

The first one needs to go to net-2.6 because it a regression:
Current code will lose multicast addresses when the automatic
recovery from stuck chip happens. Auto recovery happens a lot
under load on some configurations.

-- 
