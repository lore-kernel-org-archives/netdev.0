From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: dynamically allocated dst_ops
Date: Thu, 30 Oct 2008 07:26:22 +0300
Message-ID: <20081030042622.GA21196@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: netdev@vger.kernel.org, containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:14346 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbYJ3EXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 00:23:03 -0400
Received: by ey-out-2122.google.com with SMTP id 6so147551eyi.37
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 21:23:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are bogus and should be implanted into struct net directly.
In garbage collector hook, just use container_of() (once) to get struct net.
->dst_net is useless after that.

I'm going to use this trick for xfrm.

And if someone has ideas on how to overcome header difficulties, please,
submit a patch.
