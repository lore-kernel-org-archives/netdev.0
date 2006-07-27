From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel policy vs routing table
Date: Thu, 27 Jul 2006 16:36:59 +0200
Message-ID: <BAY103-F29E50C26FA020FFF3019DAB2580@phx.gbl>
References: <1154010436.16424.7.camel@tahini.andynet.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s25.bay0.hotmail.com ([65.54.246.161]:26282 "EHLO
	bay0-omc2-s25.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1750788AbWG0OhE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 10:37:04 -0400
In-Reply-To: <1154010436.16424.7.camel@tahini.andynet.net>
To: andy@andynet.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gay wrote:

>It's a function of the IPsec SADB. The passthrough conn added a more
>specific policy that will match before the tunnel policy.
>You can run 'ip xfrm p' and 'ip xfrm s' to view the policies & state
>info.

I did, but no results:

ip x p | grep '172.16.1.253'

nor

ip x s | grep '172.16.1.253'


