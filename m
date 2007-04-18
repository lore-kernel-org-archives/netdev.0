From: Philip Craig <philipc@snapgear.com>
Subject: Re: bug in tcp?
Date: Wed, 18 Apr 2007 10:03:02 +1000
Message-ID: <46256036.8000308@snapgear.com>
References: <E1HdZgM-0001n2-F0@highlab.com> <462450C5.5080702@snapgear.com> <E1HdgLb-0005eU-Ji@highlab.com> <46246572.9020108@snapgear.com> <E1HdoAU-0001Ao-T8@highlab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sebastian Kuzminsky <seb@highlab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:55410 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752906AbXDRAEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 20:04:08 -0400
In-Reply-To: <E1HdoAU-0001Ao-T8@highlab.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian Kuzminsky wrote:
> Why did the packet from the client cause the connection to be added back
> to the conntrack table, but the packet from the server did not?

Because the packet from the client was accepted (by a different
iptables rule).

