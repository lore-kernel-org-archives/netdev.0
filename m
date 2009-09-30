From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] bonding: send ARP requests on interfaces other
 than the primary for tlb/alb
Date: Wed, 30 Sep 2009 00:27:21 -0700 (PDT)
Message-ID: <20090930.002721.160750704.davem@davemloft.net>
References: <1254269731-7341-3-git-send-email-fubar@us.ibm.com>
	<1254269731-7341-4-git-send-email-fubar@us.ibm.com>
	<4AC2EA97.5010809@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, andy@greyhouse.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45123
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752873AbZI3H1D convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2009 03:27:03 -0400
In-Reply-To: <4AC2EA97.5010809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Sep 2009 07:20:23 +0200

> Jay Vosburgh a =E9crit :
>> -		/* The ARP relpy packets must be delayed so that
>> -		 * they can cancel out the influence of the ARP request.
>> -		 */
>=20
> COmments should have the following form :
> /*
>  * This is a fine comment
>  */

I definitely prefer what is used in the patch, whereas your suggestion
wastes a precious line on the screen and doesn't look markedly better
at all.

Look at any TCP protocol source file and you'll see the consistent
application of:

	/* This form of
	 * comment.
	 */

there.
