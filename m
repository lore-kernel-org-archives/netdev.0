From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/4] xfrm: simplify xfrm_address_t use
Date: Tue, 7 Apr 2015 18:35:21 +0200
Message-ID: <20150407183521.3a169d84@griffin>
References: <cover.1427639592.git.jbenc@redhat.com>
	<e70181767cd48da03733b6817466085c4629ff9a.1427639592.git.jbenc@redhat.com>
	<20150407090133.0cb6cf4b@urahara>
	<20150407182958.51a7b13f@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Chapman <jchapman@katalix.com>,
	Paul Moore <paul@paul-moore.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35816 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753089AbbDGQf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 12:35:27 -0400
In-Reply-To: <20150407182958.51a7b13f@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Apr 2015 18:29:58 +0200, Jiri Benc wrote:
> What could be done that should work with earlier glibc versions is
> including "utils.h" before <linux/xfrm.h> in xfrm_monitor.c. Could you
> try that? Would it be an acceptable workaround?

Or, better, include <netinet/in.h> before <linux/xfrm.h> in
xfrm_monitor.c to keep the order of inclusion of local and system
headers.

 Jiri

-- 
Jiri Benc
