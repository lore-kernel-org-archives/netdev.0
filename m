From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC/PATCH] ipg: add jumbo frame support kconfig option
Date: Tue, 26 Feb 2008 18:08:13 -0500
Message-ID: <47C49BDD.50205@garzik.org>
References: <Pine.LNX.4.64.0802262148270.12999@sbz-30.cs.Helsinki.FI> <20080226123247.2b63bbf0@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, romieu@fr.zoreil.com,
	sorbica@icplus.com.tw, jesse@icplus.com.tw,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37217 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754773AbYBZXIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 18:08:23 -0500
In-Reply-To: <20080226123247.2b63bbf0@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
>> From: Pekka Enberg <penberg@cs.helsinki.fi>
>>
>> Convert the internal JUMBO_FRAME #ifdef to CONFIG_IP1000_JUMBO_FRAME proper and
>> fix compilation errors.
>>
>> Cc: Francois Romieu <romieu@fr.zoreil.com>
>> Cc: Sorbica Shieh <sorbica@icplus.com.tw>
>> Cc: Jesse Huang <jesse@icplus.com.tw>
>> Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> 
> Please don't do this as a config option. Config options seem like a good idea
> to developers but are difficult for distributions.  Either support jumbo
> frames by default or not at all.

Agreed, but to be more specific...    always compile in jumbo frame 
support.  You don't have to enable it at runtime by default, though.

	Jeff



