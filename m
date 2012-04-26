From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 1/2] iproute2: allow IPv6 addresses for l2tp local and
 remote parameters
Date: Thu, 26 Apr 2012 09:32:21 +0100
Message-ID: <4F990815.9000007@katalix.com>
References: <1334921383-32109-1-git-send-email-jchapman@katalix.com> <1334921383-32109-2-git-send-email-jchapman@katalix.com> <20120425131311.0de3b94f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Chris Elston <celston@katalix.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:38281 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754883Ab2DZIcY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2012 04:32:24 -0400
In-Reply-To: <20120425131311.0de3b94f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/04/12 21:13, Stephen Hemminger wrote:
> On Fri, 20 Apr 2012 12:29:42 +0100
> James Chapman <jchapman@katalix.com> wrote:
> 
>> From: Chris Elston <celston@katalix.com>
>>
>> Adds support for parsing IPv6 addresses to the parameters local and
>> remote in the l2tp commands. Requires netlink attributes L2TP_ATTR_IP6_SADDR
>> and L2TP_ATTR_IP6_DADDR, added in a required kernel patch already submitted
>> to netdev.
>>
>> Also enables printing of IPv6 addresses returned by the L2TP_CMD_TUNNEL_GET
>> request.
>>
>> Signed-off-by: Chris Elston <celston@katalix.com>
>> Signed-off-by: James Chapman <jchapman@katalix.com>
> 
> Accepted.

The kernel patches that this code depends on aren't in the tree yet
(kernel header file update). It uses new netlink attributes so the
iproute2 git compile fails.

I suggest revert the patch for now. I'll resubmit when the dependencies
are in the netdev tree.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
