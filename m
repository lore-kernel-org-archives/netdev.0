From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [v4 PATCH 1/2] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Fri, 25 Nov 2011 14:19:22 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEE3@saturn3.aculab.com>
References: <1322213787-25796-2-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hans.schillstrom@ericsson.com>
To: "Hans Schillstrom" <hans@schillstrom.com>, <kaber@trash.net>,
	<pablo@netfilter.org>, <jengelh@medozas.de>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43962 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755774Ab1KYOVS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 09:21:18 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 05735-01 for <netdev@vger.kernel.org>;
 Fri, 25 Nov 2011 14:21:15 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1322213787-25796-2-git-send-email-hans@schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> +	addr1 = (__force u32) ip6->saddr.s6_addr32[3];
> +	addr2 = (__force u32) ip6->daddr.s6_addr32[3];
...
> +	ports.v32 = * (__force u32 *) (skb->data + nhoff);

Is this code even vaguely portable??
I suspect the 'ports' bit has serious endianness problems.
I'm also not sure whether linux guarantees the alignment
of skb->data here.

	David
