From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 10/10][NETNS][FRAGS]: Make the pernet
 subsystem for fragments.
Date: Tue, 22 Jan 2008 06:12:52 -0800 (PST)
Message-ID: <20080122.061252.25508569.davem@davemloft.net>
References: <4795F524.8060204@openvz.org>
	<4795F96B.8030109@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46551
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754313AbYAVOMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:12:45 -0500
In-Reply-To: <4795F96B.8030109@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 22 Jan 2008 17:10:51 +0300

> On namespace start we mainly prepare the ctl variables.
> 
> When the namespace is stopped we have to kill all the 
> fragments that point to this namespace. 
> The inet_frags_exit_net() handles it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Also applied, thanks a lot!
