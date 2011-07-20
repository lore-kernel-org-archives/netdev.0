From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Fix panic in virtnet_remove
Date: Wed, 20 Jul 2011 08:17:33 -0700
Message-ID: <20110720081733.5afa3f8c@nehalam.ftrdhcpuser.net>
References: <20110720074339.7842.72593.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56339 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980Ab1GTPRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 11:17:31 -0400
In-Reply-To: <20110720074339.7842.72593.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jul 2011 13:13:39 +0530
Krishna Kumar <krkumar2@in.ibm.com> wrote:

> Fix a panic in virtnet_remove. unregister_netdev has already
> freed up the netdev (and virtnet_info) due to dev->destructor
> being set, while virtnet_info is still required. Remove
> virtnet_free altogether, and move the freeing of the per-cpu
> statistics from virtnet_free to virtnet_remove.
> 
> Tested patch below.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Need to check veth and xen for same problem.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
