From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net 2/3] net: sctp: fix panic on duplicate ASCONF chunks
Date: Sat, 11 Oct 2014 00:02:31 +0200
Message-ID: <54385777.7090907@redhat.com>
References: <1412888133-833-1-git-send-email-dborkman@redhat.com> <1412888133-833-3-git-send-email-dborkman@redhat.com> <20141010153954.GE19499@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27029 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751787AbaJJWCm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2014 18:02:42 -0400
In-Reply-To: <20141010153954.GE19499@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2014 05:39 PM, Neil Horman wrote:
...
> Is it worth adding a WARN_ON, to indicate that two ASCONF chunks have been
> received with duplicate serials?

Don't think so, as this would be triggerable from outside.

Thanks,
Daniel
