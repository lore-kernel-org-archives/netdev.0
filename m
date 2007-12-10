From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: routing policy based on u32 classifier
Date: Mon, 10 Dec 2007 17:09:41 +0100
Message-ID: <BAY103-DAV58E11F167187474762928B26B0@phx.gbl>
References: <BAY103-DAV51710C05B584C53DED66DB26B0@phx.gbl> <5A630F46702DD1498FFD48394B4A664C347275DD@john.ad.clarku.edu> <BAY103-DAV999F982646869B2E4AABAB26B0@phx.gbl> <5A630F46702DD1498FFD48394B4A664C347275DE@john.ad.clarku.edu>
To: "Brian S Julin" <BJulin@clarku.edu>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s32.bay0.hotmail.com ([65.54.246.232]:37966 "EHLO
	bay0-omc3-s32.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751746AbXLJQLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 11:11:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian S Julin wrote:

> Almost clear... why can you not just add "src <ADSL IP>" to
> the fwmark route to set the default source address for locally
> originating packets?

IIRC, it doesn't work because netfilter isn't called
in ip source address selection.


