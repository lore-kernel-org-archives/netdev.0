From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] tcp: Remove redundant copy of MD5
 authentication key
Date: Sat, 29 Aug 2009 00:19:50 -0700 (PDT)
Message-ID: <20090829.001950.61780566.davem@davemloft.net>
References: <1250711261.7166.8.camel@Maple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56848
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751814AbZH2HTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 03:19:36 -0400
In-Reply-To: <1250711261.7166.8.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Wed, 19 Aug 2009 19:47:41 +0000

> Remove the copy of the MD5 authentication key from tcp_check_req().
> This key has already been copied by tcp_v4_syn_recv_sock() or
> tcp_v6_syn_recv_sock().
> 
> Signed-off-by: John Dykstra <john.dykstra1@gmail.com>

Applied.
