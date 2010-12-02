From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/4] net: snmp: fix the wrong ICMP_MIB_MAX value
Date: Thu, 02 Dec 2010 13:27:57 -0800 (PST)
Message-ID: <20101202.132757.229744703.davem@davemloft.net>
References: <4CF71ADB.5060702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45230
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757995Ab0LBV1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 16:27:30 -0500
In-Reply-To: <4CF71ADB.5060702@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Thu, 02 Dec 2010 12:04:43 +0800

> __ICMP_MIB_MAX is equal to the total number of icmp mib,
> So no need to add 1. This wastes 4/8 bytes memory.
> 
> Change it to be same as ICMP6_MIB_MAX, TCP_MIB_MAX, UDP_MIB_MAX.
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied.
