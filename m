From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] openvswitch: include datapath actions with
 sampled-packet upcall to userspace
Date: Mon, 01 Jun 2015 15:05:52 -0700 (PDT)
Message-ID: <20150601.150552.393218486356466761.davem@davemloft.net>
References: <CALnjE+p3DutBRfUXOWOR3Dw_SmwbxuZcTftps15=hCxs+MWLJA@mail.gmail.com>
	<1432699183-15713-1-git-send-email-neil.mckee@inmon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: neil.mckee@inmon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbbFAWFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 18:05:53 -0400
In-Reply-To: <1432699183-15713-1-git-send-email-neil.mckee@inmon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil McKee <neil.mckee@inmon.com>
Date: Tue, 26 May 2015 20:59:43 -0700

> If new optional attribute OVS_USERSPACE_ATTR_ACTIONS is added to an
> OVS_ACTION_ATTR_USERSPACE action, then include the datapath actions
> in the upcall.
> 
> This Directly associates the sampled packet with the path it takes
> through the virtual switch. Path information currently includes mangling,
> encapsulation and decapsulation actions for tunneling protocols GRE,
> VXLAN, Geneve, MPLS and QinQ, but this extension requires no further
> changes to accommodate datapath actions that may be added in the
> future.
> 
> Adding path information enhances visibility into complex virtual
> networks.
> 
> Signed-off-by: Neil McKee <neil.mckee@inmon.com>

Applied, thanks.
