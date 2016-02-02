From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 5/5] vxlan: consolidate vxlan_xmit_skb and
 vxlan6_xmit_skb
Date: Tue, 2 Feb 2016 16:06:21 +0100
Message-ID: <20160202160621.086e710c@griffin>
References: <cover.1454407418.git.jbenc@redhat.com>
	<0fb02d1526b8f5f602f78536d261713edee9b4ef.1454407418.git.jbenc@redhat.com>
	<1454425043.5523.21.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46801 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754868AbcBBPGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 10:06:25 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id D52F93B51EA
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2016 15:06:24 +0000 (UTC)
In-Reply-To: <1454425043.5523.21.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 Feb 2016 15:57:23 +0100, Paolo Abeni wrote:
> I think there is an issue here: in vxlan_build_skb(), 'flags' will be
> always tested against VXLAN_F_UDP_CSUM, but when tunneling over ipv6 we
> should check VXLAN_F_UDP_ZERO_CSUM6_TX instead. 

You're correct. This IPv4/v6 flags schism is a source of constant pain.
Thanks for noticing it.

> Probably an explicit 'udp_sum' argument should be added to
> vxlan_build_skb().

Yes, I'm already working on a patch and will resubmit the set.

Thanks,

 Jiri

-- 
Jiri Benc
