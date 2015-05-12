From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] switchdev: add support for fdb add/del/dump
 via switchdev_port_obj ops.
Date: Tue, 12 May 2015 18:20:13 -0400 (EDT)
Message-ID: <20150512.182013.447321071616691313.davem@davemloft.net>
References: <1430949253-6358-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org
To: sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753953AbbELWUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 18:20:37 -0400
In-Reply-To: <1430949253-6358-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Date: Wed,  6 May 2015 14:54:13 -0700

> - introduce port fdb obj and generic switchdev_port_fdb_add/del/dump()
> - use switchdev_port_fdb_add/del/dump in rocker/team/bonding ndo ops.
> - add support for fdb obj in switchdev_port_obj_add/del/dump()
> - switch rocker to implement fdb ops via switchdev_ops
> 
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

What is this patch even against?  I don't see switchdev_port_obj_add()
in any tree I maintain, yet this patch's context shows references to
it which should exist already.
