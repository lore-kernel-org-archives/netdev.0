From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: ipv6_chk_acast_addr remove unused loop
Date: Fri, 8 Feb 2008 09:42:52 -0800
Message-ID: <OF1B77A186.F07F897A-ON882573E9.0060B0C5-882573E9.00614E3C@us.ibm.com>
References: <47AC8FFD.3090401@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	=?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:37044 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214AbYBHRmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 12:42:55 -0500
In-Reply-To: <47AC8FFD.3090401@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NACK.

Daniel,
        This code is part of the in-kernel API for anycast, which is 
intended
to be the same as for multicast. By removing support for NULL there, 
you're
making a special case for the anycast code that isn't there in the 
multicast
code (can't support a NULL dev), and you really aren't buying all that 
much for it.

                                                        +-DLS

