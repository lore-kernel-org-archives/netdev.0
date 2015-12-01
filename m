From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] openvswitch: properly refcount vport-vxlan
 module
Date: Tue, 01 Dec 2015 16:10:27 -0500 (EST)
Message-ID: <20151201.161027.377863225523146696.davem@davemloft.net>
References: <2658801f06f24c242c40f223b1164e61be44974a.1448882748.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, tgraf@suug.ch
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57263 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbbLAVK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 16:10:29 -0500
In-Reply-To: <2658801f06f24c242c40f223b1164e61be44974a.1448882748.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Mon, 30 Nov 2015 12:31:43 +0100

> After 614732eaa12d, no refcount is maintained for the vport-vxlan module.
> This allows the userspace to remove such module while vport-vxlan
> devices still exist, which leads to later oops.
> 
> v1 -> v2:
>  - move vport 'owner' initialization in ovs_vport_ops_register()
>    and make such function a macro
> 
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks.
