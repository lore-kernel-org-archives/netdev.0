From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [Question]The benefit of weight_p in __qdisc_run
Date: Wed, 17 Dec 2014 10:20:44 +0100
Message-ID: <54914AEC.7070600@redhat.com>
References: <CA+U0gVhk+4-T=XuCumnpRnRyQ=OqVfegGxF3ZZQy07++PDOW3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dennis Chen <kernel.org.gnu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751721AbaLQJUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2014 04:20:48 -0500
In-Reply-To: <CA+U0gVhk+4-T=XuCumnpRnRyQ=OqVfegGxF3ZZQy07++PDOW3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2014 09:54 AM, Dennis Chen wrote:
> weight_p is used as the burst xmit packet quota in the while loop of
> the __qdisc_run function,
> does anybody can elaborate the benefit of the weight_p introduced
> here? what's the consequence without it?

It acts as a quota to introduce fairness among qdiscs. See also slide 7
onwards for experiments with/without it:

   http://vger.kernel.org/netconf2011_slides/jamal_netconf2011.pdf
