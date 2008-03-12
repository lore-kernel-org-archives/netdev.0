From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH][NEIGH]: Fix race between pneigh deletion and ipv6's ndisc_recv_ns
 - V2
Date: Wed, 12 Mar 2008 13:30:27 +0300
Message-ID: <47D7B0C3.1010801@openvz.org>
References: <47CFD2ED.3060207@openvz.org> <47D68817.9030709@openvz.org> <20080311.175212.74407707.davem@davemloft.net> <47D7A52D.2090007@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33194 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982AbYCLKaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2008 06:30:39 -0400
In-Reply-To: <47D7A52D.2090007@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> David Miller wrote:
>> From: Pavel Emelyanov <xemul@openvz.org>
>> Date: Tue, 11 Mar 2008 16:24:39 +0300
>>
>>> You picked up the patch with /proc/net symlink, but skipped this
>>> one, while it was sent earlier. Is it _that_ bad :) ?
>> I am travelling and giving presentations in Japan, and
>> this patch is in my backlog to look at :-)
> 
> The patch does not apply anymore due to the ndisc modification to be per 
> namespace. I modified it to take the namespace into account and 
> initialized the is_router variable to avoid a compilation warning.
> 

My patch applies to net-2.6, while yours does not. 
Which tree is it for?
