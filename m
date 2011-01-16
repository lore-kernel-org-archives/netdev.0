From: David Miller <davem@davemloft.net>
Subject: Re: [patch] 9p: fix min_t() casting
Date: Sat, 15 Jan 2011 20:52:08 -0800 (PST)
Message-ID: <20110115.205208.104051310.davem@davemloft.net>
References: <20110115203539.GF2721@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ericvh@gmail.com, sripathik@in.ibm.com, jvrao@linux.vnet.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45355
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751709Ab1APEvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jan 2011 23:51:35 -0500
In-Reply-To: <20110115203539.GF2721@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 15 Jan 2011 23:35:39 +0300

> The intent here was to cap the length to USHRT_MAX, but what the
> code actually does is it just casts the return from strlen() to
> unsigned short and truncates the significant bits away.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

If you want me to apply this, it doesn't apply cleanly to net-2.6
at all.
