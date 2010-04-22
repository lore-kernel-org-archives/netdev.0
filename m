From: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Subject: Re: [patch] wimax: checking ERR_PTR vs null
Date: Thu, 22 Apr 2010 15:56:43 -0700
Message-ID: <1271977003.2867.12.camel@localhost.localdomain>
References: <20100422095010.GN29647@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wimax@linuxwimax.org" <wimax@linuxwimax.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64694 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753631Ab0DVXAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 19:00:07 -0400
In-Reply-To: <20100422095010.GN29647@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-22 at 02:50 -0700, Dan Carpenter wrote: 
> stch_skb is allocated with wimax_gnl_re_state_change_alloc().  That
> function returns ERR_PTRs on failure and doesn't return NULL.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

ACK, thanks [and thanks to davem for reminding me]


