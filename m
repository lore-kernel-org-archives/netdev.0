From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net v2] net: sctp: test if association is dead in sctp_wake_up_waiters
Date: Wed, 09 Apr 2014 15:34:25 +0200
Message-ID: <53454C61.70007@redhat.com>
References: <de3e98e644dde7dcaea9a952de38eb32a2959eeb.1396999714.git.dborkman@redhat.com> <5345003B.8080601@redhat.com> <534521D0.7050707@redhat.com> <20140409105908.GC13412@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21725 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932748AbaDINei (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2014 09:34:38 -0400
In-Reply-To: <20140409105908.GC13412@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2014 12:59 PM, Neil Horman wrote:
...
> Both to the patch, and the documentation, as its not at all clear what lock
> protects the reading and writing of the dead variable.

Agreed, I'll send a v3 with an improved commit message to
summarize everything for future reference. Thanks everyone.
