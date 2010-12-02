From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/4] net: snmp: fix the wrong ICMP_MIB_MAX value
Date: Thu, 02 Dec 2010 09:38:04 -0800 (PST)
Message-ID: <20101202.093804.193716088.davem@davemloft.net>
References: <4CF71ADB.5060702@cn.fujitsu.com>
	<20101202095753.GA10221@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, netdev@vger.kernel.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44553
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757902Ab0LBRhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 12:37:37 -0500
In-Reply-To: <20101202095753.GA10221@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Thu, 2 Dec 2010 04:57:53 -0500

> Looks like the +1 is there to account for ICMP_MIB_DUMMY. It is
> unused though but you have to remove it as well if you want to
> kill that extra +1.

He does in patch #4

ICMP_MIB_DUMMY was used in pre-GIT times, as a throw away ICMP counter
that gets bumped when we have no specific counter that should be
bumped for an ICMP code type.  There was a table, per ICMP code,
that listed the counter to bump amongst other things, and this
dummy value was used in that table.
