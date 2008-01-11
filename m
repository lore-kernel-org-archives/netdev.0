From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-2.6.25 0/5][NETNS][IPV6] discriminate inet6
 addresses per namespace
Date: Thu, 10 Jan 2008 22:45:06 -0800 (PST)
Message-ID: <20080110.224506.10672625.davem@davemloft.net>
References: <20080110180240.517524760@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41563
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751165AbYAKGpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 01:45:07 -0500
In-Reply-To: <20080110180240.517524760@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Thu, 10 Jan 2008 19:02:40 +0100

> The inet6_addr_lst hash table contains the configured addresses 
> for the ipv6 protocol on the system.
> 
> With the network namespace, we have 2 solutions:
>  * make this hash table per namespace
>  * keep a global hash table and discard addresses not belonging
>    to the network namespace
> 
> This patchset use the second method. It will use less memory, but
> can be a less efficient in case of a lot of containers.
> 
> The code is changed to have the network namespace parameter for the
> different functions, if we change our mind during an intense usage
> of the network namespace, the switch to a hash table per namespace
> is really easy to do and will not change the new api again.

All 5 patches applied, thanks.
