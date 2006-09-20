From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] sky2: process tx pause frames.
Date: Wed, 20 Sep 2006 14:53:10 -0700
Message-ID: <20060920145310.04e75e97@localhost.localdomain>
References: <20060906124447.642940bd@localhost.localdomain>
	<45056102.2010408@pobox.com>
	<20060919141308.7e52b7d0@localhost.localdomain>
	<4511B775.4020607@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:64391 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932216AbWITVyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 17:54:03 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4511B775.4020607@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Sep 2006 17:49:41 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > This patch already is in 2.6.17 stable, but the bigger version was pushed
> > off till 2.6.19. Here is a less intrusive version that needs to go into 2.6.18
> > (or I'll end up sending it for 2.6.18.1). The driver was telling the
> > GMAC to flush (not process) pause frames. Manually disabling pause wasn't
> > working because of problems in the setup.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> You'll need to send this to stable@kernel.org...
> 
> 	Jeff

I did already thanks.
-- 
Stephen Hemminger <shemminger@osdl.org>
