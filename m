From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH][CAN]: Fix copy_from_user() results interpretation.
Date: Sat, 26 Apr 2008 08:35:24 +0200
Message-ID: <4812CD2C.30307@grandegger.com>
References: <4811D1A6.909@openvz.org>	<4811E915.80303@volkswagen.de>	<4812C973.5000504@grandegger.com> <20080425.232310.186704312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: oliver.hartkopp@volkswagen.de, xemul@openvz.org,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	urs.thuermann@volkswagen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:43927 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbYDZGf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 02:35:26 -0400
In-Reply-To: <20080425.232310.186704312.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Wolfgang Grandegger <wg@grandegger.com>
> Date: Sat, 26 Apr 2008 08:19:31 +0200
> 
>> What about removing the assignment "err =" in that case. It's confusing
>> otherwise and maybe the variable err is even obsolete.
> 
> Sure, but when fixing a bug it's better to have a completely
> localized change like this.
> 
> Not something which restructures the code unnecessarily at
> the same time, that make it so much harder to review and
> validate.

Well, really,

   if (func(x))
        return -EFAULT;

instead of

   err = func(x);
   if (err)
	return -EFAULT;

is more straight forward and less confusing and I do not understand, why
it should be harder to review.

Wolfgang.

