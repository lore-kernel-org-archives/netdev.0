From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Fri, 18 Mar 2011 15:33:04 +0100
Message-ID: <1300458784.2888.138.camel@edumazet-laptop>
References: <1300446743.11985.317.camel@firesoul.comx.local>
	 <1300453519.2888.118.camel@edumazet-laptop>
	 <1300457877.26693.53.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:65487 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591Ab1CROdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 10:33:32 -0400
Received: by fxm17 with SMTP id 17so3737479fxm.19
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 07:33:31 -0700 (PDT)
In-Reply-To: <1300457877.26693.53.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 mars 2011 =C3=A0 14:17 +0000, Ben Hutchings a =C3=A9crit=
 :

> WARN is correct as this is a driver bug.  But I agree that the
> device/driver ID should be included.

stack trace gives absolutely no useful indication here.

Bug is in driver, yet we dump information on core network stack ?

pr_err() is an error indication, not a warning by the way ;)



