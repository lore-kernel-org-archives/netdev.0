From: David Miller <davem@davemloft.net>
Subject: Re: Rules and groups
Date: Wed, 09 Aug 2006 01:01:25 -0700 (PDT)
Message-ID: <20060809.010125.78708459.davem@davemloft.net>
References: <20060809080139.GA19555@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:64903
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030434AbWHIIBp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 04:01:45 -0400
To: steve@chygwyn.com
In-Reply-To: <20060809080139.GA19555@souterrain.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Whitehouse <steve@chygwyn.com>
Date: Wed, 9 Aug 2006 09:01:39 +0100

> Is there anything to stop me using RTNLGRP_NOP3 for that? (suitable
> renamed of course!) So far as I can see its never been assigned to
> anything else...

I have no objection to you using it.

These nops exist because the table used to be a bunch of bitmask
defines instead of the present enum:

#define RTMGRP_LINK		1
#define RTMGRP_NOTIFY		2
#define RTMGRP_NEIGH		4
#define RTMGRP_TC		8

#define RTMGRP_IPV4_IFADDR	0x10
#define RTMGRP_IPV4_MROUTE	0x20
#define RTMGRP_IPV4_ROUTE	0x40

#define RTMGRP_IPV6_IFADDR	0x100
#define RTMGRP_IPV6_MROUTE	0x200
#define RTMGRP_IPV6_ROUTE	0x400

#define RTMGRP_DECnet_IFADDR    0x1000
#define RTMGRP_DECnet_ROUTE     0x4000

That is from 2.4.x
