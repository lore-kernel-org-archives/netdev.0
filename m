From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v3 net-next] net: ipv6: Add sysctl entry to disable MTU updates from RA
Date: Mon, 26 Jan 2015 18:27:09 +0100
Message-ID: <8761btxxjm.fsf@nemi.mork.no>
References: <1421773565-5181-1-git-send-email-harouth@codeaurora.org>
	<20150124.231432.1788575004982971514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: harouth@codeaurora.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37557 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753022AbbAZR1T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 12:27:19 -0500
In-Reply-To: <20150124.231432.1788575004982971514.davem@davemloft.net> (David
	Miller's message of "Sat, 24 Jan 2015 23:14:32 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> Under what circumstances would userland ignore a router advertized
> MTU, and are the RFCs ok with this?

RFC 4861 ( https://tools.ietf.org/html/rfc4861#page-54 ) says:

  "If the MTU option is present, hosts SHOULD copy the option's value
   into LinkMTU so long as the value is greater than or equal to the
   minimum link MTU [IPv6] and does not exceed the maximum LinkMTU valu=
e
   specified in the link-type-specific document (e.g., [IPv6-ETHER])."

So the RFC acknowledge that there may exist valid reasons in particular
circumstances to ignore the MTU option.  As others have stated: This
might be necessary for DoS prevention, working around bugs in other
equipment, etc.


Bj=C3=B8rn
