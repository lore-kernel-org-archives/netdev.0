From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 5/5][NETNS]: Minor information leak via
 /proc/net/ptype file.
Date: Mon, 24 Mar 2008 14:58:33 -0700 (PDT)
Message-ID: <20080324.145833.17945817.davem@davemloft.net>
References: <47E7888D.5080308@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, dlezcano@fr.ibm.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36751
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754384AbYCXV6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 17:58:40 -0400
In-Reply-To: <47E7888D.5080308@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 24 Mar 2008 13:55:09 +0300

> This file displays the registered packet types, but some of them
> (packet sockets creates such) can be bound to a net device and
> showing them in a wrong namespace is not correct.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
