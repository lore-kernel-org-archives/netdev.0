From: Jason Wang <jasowang@redhat.com>
Subject: Re: Get rxhash fixes and RFS support in tun
Date: Thu, 21 Nov 2013 13:03:06 +0800
Message-ID: <528D940A.5010803@redhat.com>
References: <alpine.DEB.2.02.1311201220510.19725@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, hkchu@google.com
To: Tom Herbert <therbert@google.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12519 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752587Ab3KUFHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 00:07:05 -0500
In-Reply-To: <alpine.DEB.2.02.1311201220510.19725@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2013 04:25 AM, Tom Herbert wrote:
> This patch series fixes some subtle bugs in tun use of skb->rxhash, all
> rxhash hash not be cleared appropraitely, and adds support for tun flows
> to work with RFS.
>
>
> Testing, in particular with tun, hasn't been completed yet.

Interesting work, did you plan to test this with a kvm guest or even a
multi-queue guest?

Thanks
