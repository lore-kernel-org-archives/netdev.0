From: Alistair Popple <alistair@popple.id.au>
Subject: Re: [PATCH] ibm emac: Don't call napi_complete if napi_reschedule failed
Date: Wed, 30 Oct 2013 10:53:36 +1100
Message-ID: <1927542.CCRJWaeNZc@mexican>
References: <1382585780-13244-1-git-send-email-alistair@popple.id.au> <20131025.191301.1496864269923138314.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:41366 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751469Ab3J2Xxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 19:53:35 -0400
In-Reply-To: <20131025.191301.1496864269923138314.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Oct 2013 19:13:01 David Miller wrote:
> The mistaken napi_complete() call and the locking change are two different
> bugs, fix them in two different patches.

OK - I've resubmitted as two separate patches.
