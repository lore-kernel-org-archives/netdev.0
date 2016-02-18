From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] vxlan: do not use fdb in metadata mode
Date: Thu, 18 Feb 2016 10:11:30 +0100
Message-ID: <20160218101135.7b19238a@griffin>
References: <6003cfff14ce8e36bfbe4929fce56d06e4ebec58.1455657466.git.jbenc@redhat.com>
	<20160218063238.GB22357@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425593AbcBRJLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:11:41 -0500
In-Reply-To: <20160218063238.GB22357@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Feb 2016 15:32:40 +0900, Simon Horman wrote:
> The logic here looks correct to me but I am curious to know
> what circumstances would lead to the kfree_skb() case.

Setting up the interface in "external" (VXLAN_F_COLLECT_METADATA) mode,
assigning an IP address and not setting a route with the "encap"
parameter.

 Jiri

-- 
Jiri Benc
