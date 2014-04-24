From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC][PATCH] IP: Make ping sockets optional
Date: Fri, 25 Apr 2014 00:59:17 +0900
Message-ID: <CAKD1Yr2_ALegmHzpeR+T3POd_PhgHAUVkf4AfjtnuDkF-KU6pw@mail.gmail.com>
References: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segoon@openwall.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:50489 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932153AbaDXP7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 11:59:38 -0400
Received: by mail-ie0-f175.google.com with SMTP id to1so2492847ieb.6
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 08:59:37 -0700 (PDT)
In-Reply-To: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2014 at 12:20 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> This is compile-tested only; I'd just like to see whether people think
> this is worth doing.

Here's a link to the original discussion about this in 2011:

http://markmail.org/thread/vcs2ui27k6yqbnmc

When I added IPv6 support to this code, I sent Yoshifuji-san patches
to iputils to use it. Unfortunately iputils hasn't seen a release
since then. I guess that's why a new binary is still required.

FWIW, Android uses this code because it does not allow setuid binaries
and so it's the only way to run ping on Android. Other distributions
(like openwall) probably have similar requirements. Of course that
doesn't mean it can't be optional. It would be nice if it wasn't
ripped out though :-)
