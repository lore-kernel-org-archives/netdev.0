From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] vxlan: Set a large MTU on ovs-created vxlan
 devices
Date: Thu, 07 Jan 2016 21:48:31 -0500 (EST)
Message-ID: <20160107.214831.1029828992750129286.davem@davemloft.net>
References: <8660z6qohn.fsf@weave.works>
	<20160107.164746.548558171283936394.davem@davemloft.net>
	<86d1tdot1f.fsf@weave.works>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: david@weave.works
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbcAHCsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 21:48:36 -0500
In-Reply-To: <86d1tdot1f.fsf@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Wragg <david@weave.works>
Date: Thu, 07 Jan 2016 23:42:52 +0000

> I'm willing to follow up on Jesse's request to look into the other
> tunnel types too, but at the moment I'm wondering what the chances are
> that the resulting submission would get accepted.

I'm ok with these fixes if you look into Jesse's feedback.

My basic gripe is that openvswitch can act as an L3 forwarding agent,
but does not contain the necessary state (f.e. topology information in
the form of a full FIB table) in order to behave like it should.
