From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: RE: IPsec and netfilter needs INPUT rule for protocol 4?
Date: Tue, 11 Jul 2006 16:11:44 +0200
Message-ID: <BAY103-F3738884C0CF149C91509B0B2680@phx.gbl>
References: <1152626083.20072.252.camel@tahini.andynet.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s7.bay0.hotmail.com ([65.54.246.143]:27829 "EHLO
	bay0-omc2-s7.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1750811AbWGKOLs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 10:11:48 -0400
In-Reply-To: <1152626083.20072.252.camel@tahini.andynet.net>
To: andy@andynet.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gay wrote:

>Since 2.6.16 it's been necessary to add an ACCEPT rule for IPIP
>(protocol 4) in the INPUT chain, otherwise IPsec tunnel mode packets get
>dropped (if your INPUT policy is DROP).
>
>I was wondering if that's the intended behavior.

No it isn't the desired behaviour. It is a know issue.


