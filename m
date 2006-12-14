From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] drivers/net/loopback.c: convert to module_init()
Date: Wed, 13 Dec 2006 16:37:14 -0800 (PST)
Message-ID: <20061213.163714.35660848.davem@davemloft.net>
References: <20061212162435.GW28443@stusta.de>
	<20061212.171756.85408589.davem@davemloft.net>
	<20061213201213.GK4587@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37140
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751876AbWLNAhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 19:37:15 -0500
To: viro@ftp.linux.org.uk
In-Reply-To: <20061213201213.GK4587@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ftp.linux.org.uk>
Date: Wed, 13 Dec 2006 20:12:14 +0000

> There might be practical considerations along the lines of "we want
> lookups for loopback to be fast"...

We have that taken care of, it's called "&loopback_dev".

None of the performance-caring paths do dev_get_by_name("lo")

