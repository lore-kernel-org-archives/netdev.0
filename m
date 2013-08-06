From: William Manley <william.manley@youview.com>
Subject: IGMP Unsolicited report interval patches
Date: Tue,  6 Aug 2013 19:03:12 +0100
Message-ID: <1375812195-6575-1-git-send-email-william.manley@youview.com>
References: <20130731063442.GA10498@order.stressinduktion.org>
To: william.manley@youview.com, netdev@vger.kernel.org, bcrl@kvack.org,
	luky-37@hotmail.com, sergei.shtylyov@cogentembedded.com,
	bhutchings@solarflare.com, davem@davemloft.net,
	hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:33863 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756078Ab3HFSEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 14:04:00 -0400
In-Reply-To: <20130731063442.GA10498@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

4th version of the patches.

The significant changes since last review are: 

1. there is a new patch (2/3) as requested by Hannes.
2. the third patch now uses IN_DEV_CONF_GET in place of
   IPV4_DEVCONF_ALL.  This means that the unsolicited report interval can
   now be configured on an interface-by-interface basis as I'd originally
   intended but messed up in the implementation.  One concern I have now
   is that with this latest patch-set is that while
   /proc/sys/net/ipv4/conf/eth0/igmp... will now have an effect 
   /proc/sys/net/ipv4/conf/all/igmp... will not.  I'm not sure how to
   resolve this.

   One option would be to have a special value of -1 to mean use the
   default so I could implement fall-back semantics.  A down-side of this
   approach is that it makes the meaning of the knobs less clear for
   someone browsing through the filesystem.  Another option would be to
   remove the knob from all/ entirely, although I'm not sure how to do
   this.  Suggestions are very much welcome :)

Thanks 

Will
