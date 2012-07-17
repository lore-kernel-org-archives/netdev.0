From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5] ipv4: Add FIB nexthop exceptions.
Date: Tue, 17 Jul 2012 16:00:05 +0200
Message-ID: <1342533605.2626.680.camel@edumazet-glaptop>
References: <20120717.061435.1733209287175819043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51867 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab2GQOAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 10:00:09 -0400
Received: by eekc13 with SMTP id c13so169965eek.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 07:00:08 -0700 (PDT)
In-Reply-To: <20120717.061435.1733209287175819043.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 06:14 -0700, David Miller wrote:
> In a regime where we have subnetted route entries, we need a way to
> store persistent storage about destination specific learned values
> such as redirects and PMTU values.
> 
> This is implemented here via nexthop exceptions.
> 
> The initial implementation is a simple linked list, and can be
> expanded to a hash table when it is shown to be justified.

Say a typical host uses a single default route, I am trying to convince
myself it can really use a simple linked list ?

Arent PMTU entries added by messages coming from untrusted sources ?
