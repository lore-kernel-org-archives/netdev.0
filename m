From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] ipv6: check return value of ipv6_get_lladdr
Date: Mon, 24 Jun 2013 09:19:54 +0200
Message-ID: <51C7F31A.1070504@redhat.com>
References: <20130623195648.GC13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752310Ab3FXHT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 03:19:56 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r5O7Juwc026769
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 03:19:56 -0400
Received: from [10.36.5.207] (vpn1-5-207.ams2.redhat.com [10.36.5.207])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r5O7JsYW020294
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 03:19:56 -0400
In-Reply-To: <20130623195648.GC13836@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/23/2013 09:56 PM, Hannes Frederic Sowa wrote:
> We should check the return value of ipv6_get_lladdr in inet6_set_iftoken.
>
> A possible situation, which could leave ll_addr unassigned is, when
> the user removed her link-local address but a global scoped address was
> already set. In this case the interface would still be IF_READY and not
> dead. In that case the RS source address is some value from the stack.
>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
