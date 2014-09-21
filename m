From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 5/8] ipv6: new function fib6_flush_trees and use it
 instead of bumping removed rt6_genid
Date: Sun, 21 Sep 2014 12:11:11 +0200
Message-ID: <1411294271.3376835.169937873.377FEBCA@webmail.messagingengine.com>
References: <cover.1411249633.git.hannes@stressinduktion.org>
 <c0a1543fe7608640f2dd1f37f8fe5978f30536d1.1411249633.git.hannes@stressinduktion.org>
 <541E3640.6020907@yoshifuji.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:33989 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750707AbaIUKLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 06:11:12 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id 2B44A207AE
	for <netdev@vger.kernel.org>; Sun, 21 Sep 2014 06:11:12 -0400 (EDT)
In-Reply-To: <541E3640.6020907@yoshifuji.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2014, at 04:21, YOSHIFUJI Hideaki wrote: 
> Now it does not "bump" the genid anymore.  Why not to change the
> function name to reflect the fact?

I first named the new function fib6_flush_trees but then realized this
function itself gets called by rt_genid_bump_all, so I left the name.
I'll append a patch to generalize those names, because it should not
matter for ipv4 or ipv6 how it is ensured that sockets drop their cached
dst_entries.

Thanks,
Hannes
