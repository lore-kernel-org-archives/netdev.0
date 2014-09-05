From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression: TCP connections fail over wireless: bad cksum?
Date: Thu, 04 Sep 2014 21:38:21 -0700
Message-ID: <1409891901.26422.133.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5408C788.4050401@tedp.id.au>
	 <1409871007.26422.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5408F3FB.2010107@tedp.id.au>
	 <CA+mtBx-5j0o6ZWhzXidLPG28ZnHBvSeCJ+hda5_hsu4Lq-_a=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ted Percival <ted@tedp.id.au>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:55153 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbaIEEi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 00:38:26 -0400
Received: by mail-pa0-f43.google.com with SMTP id et14so21625582pad.30
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 21:38:23 -0700 (PDT)
In-Reply-To: <CA+mtBx-5j0o6ZWhzXidLPG28ZnHBvSeCJ+hda5_hsu4Lq-_a=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-04 at 20:41 -0700, Tom Herbert wrote:

> Please provide 'netstat -s' to see if bad checksums are being
> reported. Also, try disabling GRO to see the effect.

Most probably this is already fixed in net-next tree

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=1f59533f9ca5634e7b8914252e48aee9d9cbe501
