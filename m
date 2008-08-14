From: "Denis V. Lunev" <den@parallels.com>
Subject: Re: [PATCH 1/2] netns: fix NULL-dereference in dev_net()
Date: Fri, 15 Aug 2008 00:20:07 +0400
Message-ID: <1218745207.16589.77.camel@iris.sw.ru>
References: <48A4871D.1030708@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	containers <containers@lists.osdl.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:5977 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767AbYHNUTi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 16:19:38 -0400
In-Reply-To: <48A4871D.1030708@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-08-14 at 15:27 -0400, Brian Haley wrote:
> Change dev_net() to handle a NULL argument - return &init_net instead.
> 
> -Brian
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> ---
> 
the code is designed keeping in mind that there are no checks for
	net != NULL
in any place. They are too expensive. We need to invent other way :(

Regards,
	Den

