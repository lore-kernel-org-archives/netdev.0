From: "Javier Cardona" <javier@cozybit.com>
Subject: Re: Proposed interface for per-packet mesh-ttl
Date: Mon, 30 Jul 2007 13:37:20 -0700
Message-ID: <445f43ac0707301337l2f7d62ebx6955a12cd89c6bd3@mail.gmail.com>
References: <445f43ac0707031149o2b50fc0en48aef4130b4b60ec@mail.gmail.com>
	 <445f43ac0707031229m4ed60e0cg7960437c3e373c8e@mail.gmail.com>
	 <20070727195616.GA31510@infradead.org>
	 <1185574942.17934.9.camel@xo-13-A4-25.localdomain>
	 <20070728073145.57155e03@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Dan Williams" <dcbw@redhat.com>,
	"Christoph Hellwig" <hch@infradead.org>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.180]:18772 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967136AbXG3UhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 16:37:22 -0400
Received: by el-out-1112.google.com with SMTP id j27so245699elf
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2007 13:37:21 -0700 (PDT)
In-Reply-To: <20070728073145.57155e03@oldman>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On 7/27/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> In this case perhaps you can have a table that maps skb->priority to
> mesh ttl? priorty can already by handled by existing setsockopt calls,
> and modified by netfilter and QoS managements.

Thanks for the feedback.  IMHO overloading the [SOL_SOCKET]
SO_PRIORITY  sockoption for something as different as changing the
mesh-ttl is quite a stretch.   But I admit that it meets the driver
requirements of "never add sockopt" and "not [ab]use netfilter hooks".
 If that's acceptable to all, I'll modify the patch in that direction.

Cheers,

Javier
