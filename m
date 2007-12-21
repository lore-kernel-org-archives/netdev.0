From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH net-2.6.25 3/3] Uninline the inet_twsk_put function
Date: Fri, 21 Dec 2007 18:53:51 +0100
Message-ID: <200712211853.52230.netdev@axxeo.de>
References: <4768F8CD.2050209@openvz.org> <200712201932.45900.netdev@axxeo.de> <20071220.160840.140150524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:4956 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752258AbXLURyI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 12:54:08 -0500
In-Reply-To: <20071220.160840.140150524.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Miller schrieb:
> "inet_timewait_sock" begins with a "struct sock_common"
> which is where the atomic_t is, and:
> 
> #define tw_refcnt		__tw_common.skc_refcnt
> 
> So you would have to change struct sock_common over to kref, and thus
> the entire networking, in order to make such a change.

Ok, that sounds too much. Many thanks for following up and taking the time
to explain it.
 
> But you would have seen this instantly if you had spent 5 seconds
> looking at how these datastructures are defined.  Instead you choose
> to make me do it and explain it to you instead.

Sorry, just matched the wrong pattern here :-)


Best Regards

Ingo Oeser
