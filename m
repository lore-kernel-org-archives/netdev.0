From: James Chapman <jchapman@katalix.com>
Subject: Re: [RFC PATCH 0/8] l2tp: introduce L2TPv3 support
Date: Tue, 24 Feb 2009 09:17:18 +0000
Message-ID: <49A3BB1E.8040005@katalix.com>
References: <20090224063908.GA20652@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:54755 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752881AbZBXJRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 04:17:31 -0500
In-Reply-To: <20090224063908.GA20652@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> James Chapman <jchapman@katalix.com> wrote:
>> This patch series implements L2TPv3. It replaces the existing pppol2tp
>> driver with a number of separate drivers, namely:-
>>
>> l2tp_core    - L2TP driver core. Always required.
>> l2tp_ppp     - L2TP PPP
>> l2tp_eth     - L2TPv3 ethernet pseudowire
>> l2tp_ip      - L2TPv3 IP encapsulation
>> l2tp_netlink - L2TPv3 netlink API
> 
> Have you thought by using the rtnl_link_ops interface instead
> of your own netlink API?

I did, yes. I decided against it only because I didn't want to cause
confusion with what I perhaps wrongly perceive as an API for managing
net devices. In the L2TPv3 case, there might not be a netdev directly
associated with a newlink API call, for example. I've no problem with
switching the code to use it if it is preferred.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

