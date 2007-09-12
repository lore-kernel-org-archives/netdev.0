From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: Cleanly handle a missing peer_tb argument on
 creation.
Date: Wed, 12 Sep 2007 06:31:39 -0700 (PDT)
Message-ID: <20070912.063139.55741343.davem@davemloft.net>
References: <m17imwaumb.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, kaber@trash.net, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:36248
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752507AbXILNcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 09:32:14 -0400
In-Reply-To: <m17imwaumb.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 12 Sep 2007 07:19:56 -0600

> 
> I was getting strange kernel crashes when attempting to
> create veth devices when I did not specify a peer argument
> to /bin/ip.
> 
> So this patch defaults peer_tb to all zeros and doesn't attempt to
> reuse the netlink attributes for the primary link to create the
> secondary link and now I can't reproduce the failures.
> 
> Given that some of the most interesting netlink attributes to specify
> like a mac address or a network device name seem are generally
> the wrong thing to do this seems like the right approach.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

This looks mostly fine, can someone else who knows
veth a bit review this as well?
