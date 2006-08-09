From: Daniel Phillips <phillips@google.com>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Tue, 08 Aug 2006 18:35:42 -0700
Message-ID: <44D93BEE.4000001@google.com>
References: <20060808193325.1396.58813.sendpatchset@lappy>	<20060808193345.1396.16773.sendpatchset@lappy> <20060808.151020.94555184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:60906 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP
	id S1030402AbWHIBgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 21:36:02 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060808.151020.94555184.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

David Miller wrote:
> I think the new atomic operation that will seemingly occur on every
> device SKB free is unacceptable.

Alternate suggestion?

> You also cannot modify netdev->flags in the lockless manner in which
> you do, it must be done with the appropriate locking, such as holding
> the RTNL semaphore.

Thanks for the catch.

Regards,

Daniel



