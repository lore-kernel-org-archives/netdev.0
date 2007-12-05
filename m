From: David Miller <davem@davemloft.net>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Tue, 04 Dec 2007 22:07:44 -0800 (PST)
Message-ID: <20071204.220744.166144729.davem@davemloft.net>
References: <47544896.7070101@candelatech.com>
	<m18x4axrx2.fsf@ebiederm.dsl.xmission.com>
	<4755A2FD.9020608@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, kaber@trash.net,
	shemminger@linux-foundation.org, lkml@rtr.ca,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49259
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750993AbXLEGHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 01:07:45 -0500
In-Reply-To: <4755A2FD.9020608@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 04 Dec 2007 10:57:01 -0800

> echo add_my_bridge my_br1 eth0 namespaceX eth1 namespaceY > 
> /proc/net/foo/config

Each process executes in a namespace, so specifying the namespace
is redundant, just fetch the current process's namespace to pass
into the dev_get_by_*() routines.

Anyone interested in using a different namespace's devices
can change the namespace the process is executing in before
the procfs echo.
