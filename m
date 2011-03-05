From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 8/8] net: get rid of orig_dev parameter of
 packet handlers
Date: Sat, 5 Mar 2011 16:15:09 +0100
Message-ID: <20110305151509.GF8573@psychotron.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
 <1299320969-7951-9-git-send-email-jpirko@redhat.com>
 <4D72512C.2060802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238Ab1CEPPq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 10:15:46 -0500
Content-Disposition: inline
In-Reply-To: <4D72512C.2060802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Mar 05, 2011 at 04:05:16PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 05/03/2011 11:29, Jiri Pirko a =E9crit :
>>Since orig_dev was used in af_packet (where it was replaced) and by
>>bonding ptype handlers (which are no longer with us) only, orig_dev
>>parameter is no longer needed ->  toss it out
>>
>>Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>
>[snip]
>>-	new->deliver_no_wcard	=3D old->deliver_no_wcard;
>
>deliver_no_wcard was removed from sk_buff in your #7 patch. Shouldn't
>the above line be part of the #7 patch?

Indeed, I wonder how if got here. Will repost to correct this.
>
>Except from this point,
>
>Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
>
>	Nicolas.
