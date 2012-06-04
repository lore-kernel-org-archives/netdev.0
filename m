From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH 1/1] net/hyperv: Use wait_event on outstanding sends
 during device removal
Date: Mon, 4 Jun 2012 16:14:12 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DD6F80B@TK5EX14MBXC223.redmond.corp.microsoft.com>
References: <1338820532-2345-1-git-send-email-haiyangz@microsoft.com>
	<1338820532-2345-2-git-send-email-haiyangz@microsoft.com>
 <20120604.114803.742884170282591530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:14303
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754055Ab2FDQO1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 12:14:27 -0400
In-Reply-To: <20120604.114803.742884170282591530.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, June 04, 2012 11:48 AM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org
> Subject: Re: [PATCH 1/1] net/hyperv: Use wait_event on outstanding sends
> during device removal
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Mon,  4 Jun 2012 07:35:32 -0700
> 
> > +	wait_event(net_device->wait_drain,
> > +		atomic_read(&net_device->num_outstanding_sends) == 0);
> 
> Please indent this properly.  The goal is not to indent using only
> TAB characters, the goal is to line things up to the proper column
> using TAB and space characters as needed.
> 
> You must make the first character on the second line be at the
> first column after the openning parenthesis on the previous line.

Will do.

Thanks,
- Haiyang 
