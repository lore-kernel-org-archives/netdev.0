From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: What now when we're [almost] out of ADVERTISED bits?
Date: Sun, 29 Nov 2015 13:53:51 +0000
Message-ID: <CO2PR11MB00887F0A656EFB801BA2599797010@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0113.outbound.protection.outlook.com ([65.55.169.113]:24276
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752812AbbK2Nx6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 08:53:58 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[I suspect there was probably some discussion over this,
but I couldn't find it; References would be welcome]

So it appears we're almost out of bits for new advertised speeds;
I'm currently looking at adding 100g.

Assuming we want [and we do want] to have those in the `supported',
`advertising' and `lp_advertising' fields, the 2 reserve fields in
ethtool_cmd would not be sufficient [unless we break them into 4 u16].
Or are we planning something more generic than this for future bits?

Following with a slightly [but related] topic, what's our policy for
non-finalized standards? Specifically, for 25Gb and 50Gb?

Thanks,
Yuval
