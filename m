From: David Miller <davem@davemloft.net>
Subject: Re: /proc/net/igmp group address encoding
Date: Mon, 06 Oct 2008 14:59:02 -0700 (PDT)
Message-ID: <20081006.145902.144784971.davem@davemloft.net>
References: <b25312890809242344n11e61c80w1bf761c55c29a65e@mail.gmail.com>
	<OFC83E5520.1D27DF52-ON882574CF.0028A6D4-882574CF.0029B829@us.ibm.com>
	<b25312890809250059y2528ec00leb95574508eb52e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, pekkas@netcore.fi
To: roszenrami@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48687
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753805AbYJFV70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 17:59:26 -0400
In-Reply-To: <b25312890809250059y2528ec00leb95574508eb52e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <roszenrami@gmail.com>
Date: Thu, 25 Sep 2008 10:59:13 +0300

> > since I believe netstat expects to see this the way it is.
> Thanks  for drawing my attention to this; due to this , displaying in
> quad format should not be implemented.

Indeed, netstat even seems to transparently handle the fact that the
value is kept in big-endian (rather than being converted using
be32_to_cpu()) as it is printed by the kernel, regardless of cpu
endianness.
