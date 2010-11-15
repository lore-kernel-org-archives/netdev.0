From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] net: remove check for headroom in
 vlan_dev_create
Date: Mon, 15 Nov 2010 10:12:04 -0800 (PST)
Message-ID: <20101115.101204.102552425.davem@davemloft.net>
References: <20101031002232.8691.41201.stgit@jf-dev1-dcblab>
	<20101031002237.8691.6266.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46383
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755364Ab0KOSLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 13:11:39 -0500
In-Reply-To: <20101031002237.8691.6266.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Sat, 30 Oct 2010 17:22:37 -0700

> It is possible for the headroom to be smaller then the
> hard_header_len for a short period of time after toggling
> the vlan offload setting.
> 
> This is not a hard error and skb_cow_head is called in
> __vlan_put_tag() to resolve this.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
