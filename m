From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next] net: make packet_type->ak_packet_priv generic
Date: Fri, 04 Apr 2014 07:33:12 -0700
Message-ID: <1396621992.12330.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396614038-31975-1-git-send-email-jiri@resnulli.us>
		<20140404.095420.1460518706334112992.davem@davemloft.net>
		<20140404140325.GB2892@minipsycho.brq.redhat.com>
	 <20140404.100754.1337061118939924472.davem@davemloft.net>
	 <533EC05C.50902@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	netdev@vger.kernel.org, edumazet@google.com, vfalico@redhat.com,
	stephen@networkplumber.org, hkchu@google.com, dborkman@redhat.com,
	willemb@google.com, hannes@stressinduktion.org,
	atzm@stratosphere.co.jp, phil@nwl.cc, richardcochran@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:50134 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752844AbaDDOdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 10:33:10 -0400
Received: by mail-pa0-f45.google.com with SMTP id kl14so3549046pab.4
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 07:33:10 -0700 (PDT)
In-Reply-To: <533EC05C.50902@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-04-04 at 16:23 +0200, Nicolas Dichtel wrote:

> Sure, the subject is very clear. Personally I don't care, but I think that a
> part of netdev subscribers/submitters don't read every emails. Having always
> the same prefix (like the one you already used: '[README]') may ease these guys
> to put some filters to highlight these emails. At the end, this may also save
> you time ;-)
> 
> My two cents,

My 2 cents would be for a developer to use updated git tree before
submitting a patch, right ?

Then, if you simply do following its pretty obvious :

$ git show | head -8
commit cd6362befe4cc7bf589a5236d2a780af2d47bcc9
Merge: 0f1b1e6d73cb b1586f099ba8
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Wed Apr 2 20:53:45 2014 -0700

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
    
    Pull networking updates from David Miller:
