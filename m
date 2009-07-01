From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default	configurable
Date: Wed, 01 Jul 2009 10:57:02 +0200
Message-ID: <4A4B24DE.10103@trash.net>
References: <1246379267.3749.42.camel@blaa> <20090630170027.GA22691@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52415 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbZGAI5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 04:57:06 -0400
In-Reply-To: <20090630170027.GA22691@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Jun 30, 2009 at 05:27:47PM +0100, Mark McLoughlin wrote:
>> However, because nf_conntrack introduces an skb_orphan(), it is now
>> recommended that bridge-nf-call-iptables be disabled completely so as
>> to ensure features like TUNSETSNDBUF work as expected.
> 
> Patrick, does conntrack ever make sense for bridging? Perhaps
> we should get rid of that completely?

People are apparently using this for stateful tracking and even
NAT on bridges, so I'm afraid we can't get rid of it completely.
