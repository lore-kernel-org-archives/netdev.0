From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch net-next] net: clean up skb headers code
Date: Thu, 30 May 2013 16:30:32 +0400
Message-ID: <51A74668.30009@cogentembedded.com>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com>  <20130528.233647.1209227470109213894.davem@davemloft.net>  <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com> <1369879142.2903.0.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	horms@verge.net.au
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:34619 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121Ab3E3Mab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 08:30:31 -0400
Received: by mail-lb0-f178.google.com with SMTP id w10so477852lbi.9
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 05:30:29 -0700 (PDT)
In-Reply-To: <1369879142.2903.0.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 30-05-2013 5:59, Cong Wang wrote:

>>> So something like "X = (typeof(X)) ~0U;".

>> I think you mean ~(typeof(X))0.


> Good catch,

    I doubt it.

> I will change it to ~(typeof(X))0.

    Then (typeof(X))0 will be promoted to *int* before doing ~.

WBR, Sergei
