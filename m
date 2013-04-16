From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH v4] vxlan: Allow setting destination to unicast address.
Date: Tue, 16 Apr 2013 09:56:15 -0400
Message-ID: <OF88AC4A33.EEA9E994-ON85257B4F.004C7B68-85257B4F.004C901F@us.ibm.com>
References: <877gk2r64z.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David S. Miller" <davem@davemloft.net>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:53479 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935487Ab3DPOBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 10:01:43 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 16 Apr 2013 08:01:41 -0600
In-Reply-To: <877gk2r64z.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 04/16/2013 08:50:52 AM:

> From: Atzm Watanabe <atzm@stratosphere.co.jp>

> This patch allows setting VXLAN destination to unicast address.
> It allows that VXLAN can be used as peer-to-peer tunnel without
> multicast.
> 
> v4: generalize struct vxlan_dev, "gaddr" is replaced with vxlan_rdst.
>     "GROUP" attribute is replaced with "REMOTE".
>     they are based by David Stevens's comments.
> 
> v3: move a new attribute REMOTE into the last of an enum list
>     based by Stephen Hemminger's comments.
> 
> v2: use a new attribute REMOTE instead of GROUP based by
>     Cong Wang's comments.
> 
> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>

Acked-by: David L Stevens <dlstevens@us.ibm.com>
