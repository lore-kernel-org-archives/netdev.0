From: David Miller <davem@davemloft.net>
Subject: Re: iproute2 showing wrong number of bytes on 64bit architectures.
Date: Tue, 10 Jul 2007 11:05:45 -0700 (PDT)
Message-ID: <20070710.110545.112620737.davem@davemloft.net>
References: <20070710085640.128311d1@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55168
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758887AbXGJSFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 14:05:22 -0400
In-Reply-To: <20070710085640.128311d1@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 10 Jul 2007 08:56:40 -0700

> Looks like net_device_stats should have always used u32?

It used unsigned long ages ago, and ifconfig gets the bits
exported from /proc/net/dev output whereas we have to used
fixed data types in whatever we use over netlink so u32
was choosen.
