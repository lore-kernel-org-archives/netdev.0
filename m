From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/4] include - Convert IP4 address class
 macros to inline functions
Date: Mon, 19 Nov 2007 21:46:55 -0800 (PST)
Message-ID: <20071119.214655.247082473.davem@davemloft.net>
References: <1195055603.5163.179.camel@localhost>
	<OF456A1240.FCBC428E-ON88257393.005C5D94-88257393.005CA64F@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, jmorris@namei.org, kaber@coreworks.de,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37050
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753437AbXKTFq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 00:46:56 -0500
In-Reply-To: <OF456A1240.FCBC428E-ON88257393.005C5D94-88257393.005CA64F@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Wed, 14 Nov 2007 08:53:13 -0800

> Maybe I'm more used to hex, but I personally don't think those are
> more readable. It replaces 1-line macroes with 4-line functions, and
> I think more vgrepping to pick out the relevant constant data.

Yes, the readability is agruable but I like the type checking.

I would also change the names, it's a better idea to prefix the
names with a namespace for the stuff being operated on, therefore
I'd prefer names like "ipv4_is_loopback()" etc.

I'm dropping these patches for now.
