From: "Dan Rosenberg" <drosenberg@vsecurity.com>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socketfilters
Date: Wed, 10 Nov 2010 18:25:57 +0000
Message-ID: <504359883-1289413568-cardhu_decombobulator_blackberry.rim.net-525501751-@bda083.bisx.prod.on.blackberry>
Reply-To: drosenberg@vsecurity.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, stable@kernel.org, security@kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp04.bis.na.blackberry.com ([216.9.248.51]:36955 "EHLO
	smtp04.bis.na.blackberry.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752041Ab0KJS0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 13:26:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apologies for the terseness, I'm not looking for a fight.

I agree the memset is too expensive, and that Eric's fix is far better.

-Dan

------Original Message------
From: David Miller
To: drosenberg@vsecurity.com
Cc: netdev@vger.kernel.org
Cc: stable@kernel.org
Cc: security@kernel.org
Subject: Re: [PATCH] Prevent reading uninitialized memory with socketfilters
Sent: Nov 10, 2010 1:21 PM

From: "Dan Rosenberg" <drosenberg@vsecurity.com>
Date: Wed, 10 Nov 2010 18:18:08 +0000

> The code sample I linked to clearly demonstrates exactly how to
> accomplish this, if you had bothered to read it.

I told you why I didn't read it, if you had bothered to read my
reply properly :-)

Anyways, I realize we have to do something, but memset() is going
to completely kill performance.  I consider Eric's suggestion the
closest to acceptable cost at this point but even that is hard
to digest for me.

