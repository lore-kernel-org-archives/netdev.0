From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] C/R: Add checkpoint support for veth devices (v2)
Date: Fri, 26 Feb 2010 04:09:10 -0800 (PST)
Message-ID: <20100226.040910.45797734.davem@davemloft.net>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
	<1267130595-23637-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, benjamin.thery@bull.net, den@openvz.org,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: danms@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38677
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934992Ab0BZMIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:08:52 -0500
In-Reply-To: <1267130595-23637-4-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>
Date: Thu, 25 Feb 2010 12:43:12 -0800

> Adds an ndo_checkpoint() handler for veth devices to checkpoint themselves.
> Writes out the pairing information, addresses, and initiates a checkpoint
> on the peer if the peer won't be reached from another netns.  Throws an
> error of our peer's netns isn't already in the hash (i.e., a tree leak).
> 
> Changes in v2:
>  - Fix check detecting if peer is in the init netns
> 
> Signed-off-by: Dan Smith <danms@us.ibm.com>

Acked-by: David S. Miller <davem@davemloft.net>
