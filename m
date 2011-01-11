From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] phonet: some signedness bugs
Date: Mon, 10 Jan 2011 16:06:20 -0800 (PST)
Message-ID: <20110110.160620.133889003.davem@davemloft.net>
References: <20110107203755.GB1959@bicker>
	<201101100958.32549.remi.denis-courmont@nokia.com>
	<20110110140658.GB2721@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, dan.j.rosenberg@gmail.com
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56470
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752823Ab1AKAFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 19:05:49 -0500
In-Reply-To: <20110110140658.GB2721@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Mon, 10 Jan 2011 17:06:58 +0300

> Dan Rosenberg pointed out that there were some signed comparison bugs
> in the phonet protocol.
> 
> http://marc.info/?l=full-disclosure&m=129424528425330&w=2
> 
> The problem is that we check for array overflows but "protocol" is
> signed and we don't check for array underflows.  If you have already
> have CAP_SYS_ADMIN then you could use the bugs to get root, or someone
> could cause an oops by mistake.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
