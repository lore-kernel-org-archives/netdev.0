From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.2)
Date: Thu, 15 Nov 2007 20:48:10 +0900 (JST)
Message-ID: <20071115.204810.131957203.yoshfuji@linux-ipv6.org>
References: <4739D7F7.90300@hp.com>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladislav.yasevich@hp.com,
	yoshfuji@linux-ipv6.org
To: Fred.L.Templin@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33179 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755184AbXKOLsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 06:48:11 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com> (at Wed, 14 Nov 2007 22:44:17 -0800), "Templin, Fred L" <Fred.L.Templin@boeing.com> says:

> From: Fred L. Templin <fred.l.templin@boeing.com>
> 
> This patch includes support for the Intra-Site Automatic Tunnel
> Addressing Protocol (ISATAP) per RFC4214. It uses the SIT
> module, and is configured using extensions to the "iproute2"
> utility.
> 
> The following diffs are specific to the Linux 2.6.24-rc2 kernel
> distribution. This message includes the full and patchable diff text;
> please use this version to apply patches.
> 
> Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

BTW, how will we handle DNS name (and TTL) and/or multiple PRL entries 
in RFC4214?

I'm doubting if we really need to handle PRL refresh in kernel.

--yoshfuji
