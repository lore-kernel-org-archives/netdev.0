From: David Miller <davem@redhat.com>
Subject: Re: [net PATCH] via-rhine: fix dma mapping errors
Date: Fri, 12 Jul 2013 16:28:46 -0700 (PDT)
Message-ID: <20130712.162846.1944261225511882226.davem@redhat.com>
References: <1373650533-20269-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rl@hellgate.ch
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755188Ab3GLX24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jul 2013 19:28:56 -0400
In-Reply-To: <1373650533-20269-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 12 Jul 2013 13:35:33 -0400

> this bug:
> https://bugzilla.redhat.com/show_bug.cgi?id=951695
> 
> Reported a dma debug backtrace:
 ...
> Usual problem with the usual fix, add the appropriate calls to dma_mapping_error
> where appropriate
> 
> Untested, as I don't have hardware, but its pretty straightforward
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Also applied, thanks Neil.
