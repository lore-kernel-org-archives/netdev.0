From: Daniel Phillips <phillips@google.com>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Tue, 08 Aug 2006 18:34:43 -0700
Message-ID: <44D93BB3.5070507@google.com>
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060808193345.1396.16773.sendpatchset@lappy> <20060808211731.GR14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:25322 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP
	id S1030401AbWHIBe4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 21:34:56 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060808211731.GR14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
  > skb->dev is not guaranteed to still point to the "allocating" device
> once the skb is freed again so reserve/unreserve isn't symmetric.
> You'd need skb->alloc_dev or something.

Can you please characterize the conditions under which skb->dev changes
after the alloc?  Are there writings on this subtlety?

Regards,

Daniel

