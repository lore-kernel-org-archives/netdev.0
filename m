From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Date: Sat, 12 Aug 2006 17:46:07 -0700 (PDT)
Message-ID: <20060812.174607.44371641.davem@davemloft.net>
References: <20060812084713.GA29523@2ka.mipt.ru>
	<1155374390.13508.15.camel@lappy>
	<20060812093706.GA13554@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, riel@redhat.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	phillips@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19101
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932621AbWHMAps (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 20:45:48 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060812093706.GA13554@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Sat, 12 Aug 2006 13:37:06 +0400

> Does it? I though it is possible to only have 64k of working sockets per
> device in TCP.

Where does this limit come from?

You think there is something magic about 64K local ports,
but if remote IP addresses in the TCP socket IDs are all
different, number of possible TCP sockets is only limited
by "number of client IPs * 64K" and ram :-)
