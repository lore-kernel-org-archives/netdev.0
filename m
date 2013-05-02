From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v7 4/6] vxlan: add ipv6 support
Date: Thu, 02 May 2013 04:10:55 -0400 (EDT)
Message-ID: <20130502.041055.1356963516697085805.davem@davemloft.net>
References: <1367313956.3216.18.camel@cr0>
	<87mwsgcnoy.fsf@nemi.mork.no>
	<1367481953.2415.29.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, netdev@vger.kernel.org, dlstevens@us.ibm.com,
	stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303Ab3EBILA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 04:11:00 -0400
In-Reply-To: <1367481953.2415.29.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu, 02 May 2013 16:05:53 +0800

> bindv6only is default to be 0

Distributions have set it by default to '1' in /etc/sysctl.conf at one
time or another.  Debian is one such example.

Many people set disable_ipv6.

So neither are corner cases.
