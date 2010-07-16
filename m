From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index>
 mapping
Date: Fri, 16 Jul 2010 13:04:45 -0700 (PDT)
Message-ID: <20100716.130445.149851386.davem@davemloft.net>
References: <AANLkTilhSSh1kE5ZfqVDbBJJWdP3hDcXRffpQwdyMQua@mail.gmail.com>
	<20100716.124031.220080717.davem@davemloft.net>
	<AANLkTinAiJJqhrro8Jlrb0WgHzDSCx_dtWXL5N9ZKUbd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, Chetan.Loke@netscout.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: chetanloke@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38199
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754883Ab0GPUE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 16:04:29 -0400
In-Reply-To: <AANLkTinAiJJqhrro8Jlrb0WgHzDSCx_dtWXL5N9ZKUbd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chetan Loke <chetanloke@gmail.com>
Date: Fri, 16 Jul 2010 16:02:23 -0400

> So all user space apps should replicate code when all of that can be
> replaced at the cost of a single for-loop in a non fast-path code
> within the kernel?

When there is a way to do something already, we don't add "yet another"
way to do it.  The kernel already suffers from API masterbation as-is.
