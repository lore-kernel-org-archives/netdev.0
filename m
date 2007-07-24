From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2.6 patch] drivers/net/acenic.c: fix check-after-use
Date: Tue, 24 Jul 2007 16:37:25 -0400
Message-ID: <46A66305.9090904@garzik.org>
References: <20070723080232.GF26212@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jes@trained-monkey.org, linux-acenic@sunsite.dk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59016 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754909AbXGXUhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 16:37:35 -0400
In-Reply-To: <20070723080232.GF26212@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> The Coverity checker noted that we've already dereferenced "dev" when we 
> check whether it's NULL.
> 
> Since it's impossible that "dev" is NULL at this place this patch 
> removes the NULL check.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

applied


