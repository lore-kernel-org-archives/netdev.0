From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [NET] [ISDN]: Do not validate ISDN net device address
	prior to interface-up
Date: Mon, 14 Apr 2008 06:07:20 +0000
Message-ID: <20080414060720.GB4016@ff.dom.local>
References: <20080414060114.GA4016@ff.dom.local> <4802F24B.7060104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pebolle@tiscali.nl,
	netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	jgarzik@redhat.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:33785 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407AbYDNGEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:04:43 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1446141fgb.17
        for <netdev@vger.kernel.org>; Sun, 13 Apr 2008 23:04:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4802F24B.7060104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 14, 2008 at 07:57:31AM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
...
>> Maybe I missed Patrick point, but it seems this patch isn't good:
>> it omits address validation hiding possible problems.
> The ISDN device's address is computed from the IP addresses
> in ->open(), so there is nothing to validate at the time
> eth_validate_addr() is called.

...So I missed the point, sorry!

Thanks for the explanation,
Jarek P.
