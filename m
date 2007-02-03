From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH][XFRM][0/5] extension for XFRM databases
Date: Sat, 03 Feb 2007 08:45:57 -0500
Message-ID: <1170510358.3979.4.camel@localhost>
References: <20070202132129.E2EA.SHINTA@sfc.wide.ad.jp>
	 <1170423351.4000.42.camel@localhost>
	 <20070203085225.E309.SHINTA@sfc.wide.ad.jp>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	usagi-core@linux-ipv6.org
To: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:31768 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbXBCNqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 08:46:01 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1142925wxd
        for <netdev@vger.kernel.org>; Sat, 03 Feb 2007 05:46:01 -0800 (PST)
In-Reply-To: <20070203085225.E309.SHINTA@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-03-02 at 09:28 +0900, Shinta Sugimoto wrote:

> Yes.  A XFRM_MSG_MIGRATE message can update an SPD entry and associated
> SAD entries (if any) at a time.
> 

Ok, you have convinced me on the need for the message.

> By "Mobile VPN", I meant a VPN scenario where clients roam around
> subnets and continue changing its attachment point to the Internet
> (aka roadwarrior).  In such case, both client and SGW need to update
> endpoint address of the security association.  When the endpoint address
> of client side is updated, instead of re-establishing the security
> association from scratch, the client may inform the SGW of its new
> endpoint address.  This is what MOBIKE (RFC4555) does.  So, just like
> in the case of Mobile IPv6, endpoint address management of IPsec
> databases is necessary and XFRM_MSG_MIGRATE message can be used.

makes a lot of sense.

Thanks for your patience Shinta.

cheers,
jamal

