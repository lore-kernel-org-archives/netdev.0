From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 02/11] igb: Use node specific allocations for the
 q_vectors and rings
Date: Mon, 10 Oct 2011 13:50:28 -0400 (EDT)
Message-ID: <20111010.135028.1975552298597502010.davem@davemloft.net>
References: <1318056461-19562-3-git-send-email-jeffrey.t.kirsher@intel.com>
	<20111008.155158.566839176815794249.davem@davemloft.net>
	<4E931A06.7090805@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800Ab1JJRum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 13:50:42 -0400
In-Reply-To: <4E931A06.7090805@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 10 Oct 2011 09:15:02 -0700

> Actually the main reason for having adapter->node is because in our
> out-of-tree driver we end up using it as a module parameter in the event
> that someone is running in single queue mode and wants to split up the
> ports between nodes.  As such I would prefer to keep the parameter
> around and just default it to -1 as I am currently doing.  However if it
> must go I guess I can work around that sync-up issue.

Please stop adding such hacks to your out-of-tree driver and add
appropriate, generic, configure mechanisms to the upstream tree.

It absolutely is not appropriate to add something which is completely
useless to the upstream tree for the sake of something being done
only externally.

You guys are the best at upstream net driver maintainence, so it
really surprises me that you continue to do completely unacceptable
crap like this.  Write the necessary generic non-module-option
mechanisms to facilitate the features you need and kill your out of
tree driver _now_.
