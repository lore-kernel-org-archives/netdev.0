From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC] IPv6 route replacement
Date: Wed, 22 Jul 2009 20:09:10 +0900
Message-ID: <4A66F356.3000803@linux-ipv6.org>
References: <20090722095040.GC3517@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi,
	kaber@trash.net, yoshfuji@linux-ipv6.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41615 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750953AbZGVLSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 07:18:10 -0400
In-Reply-To: <20090722095040.GC3517@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Jiri Pirko wrote:
> Now do you think this is the right behaviour? I would expect the first route to
> be replaced. The same result is when you do "ip -6 route replace"

Well, even in IPv4 you cannot change metric;
same route can be installed e.g., for manual
backup route entry.

But well, NLM_F_REPLACE handler is completely
missing in IPv6.  I think we are okay with
"replace" (NLM_F_CREATE|NLM_F_REPLACE) but we
could return "no such route" for "change"
(NLM_F_REPLACE).

--yoshfuji
