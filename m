From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bonding,llc: Fix structure sizeof incompatibility for
 some PDUs
Date: Thu, 12 May 2011 15:33:36 +0100
Message-ID: <1305210816.5214.9.camel@bwh-desktop>
References: <201105121557.06679.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:4927 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757527Ab1ELOdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 10:33:40 -0400
In-Reply-To: <201105121557.06679.vitas@nppfactor.kiev.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 15:57 +0300, Vitalii Demianets wrote:
> With some combinations of arch/compiler the sizeof operator on structure 
> returns value greater than expected.

Yes, some architecture ABIs set a minimum alignment for structures so
they can have greater alignment than any of their members.

> In cases when the structure is used for 
> mapping PDU fields it may lead to unexpected results (e.g. holes and 
> alignment problems in skb data). Attribute "packed" prevents this undesired 
> behavior.
[...]

The '__packed' macro is preferred.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

