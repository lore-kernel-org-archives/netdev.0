From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: Re: [PATCH v2] Implement IP_UNICAST_IF socket option.
Date: Fri, 3 Feb 2012 08:21:13 -0700
Message-ID: <CAEU2+vrMKjLXyABZhi5QrUBA=Fvd4ExgMxjD+T376AZW1SRd8A@mail.gmail.com>
References: <1328218567-3134-1-git-send-email-ehoover@mines.edu>
	<1328219828.2480.32.camel@edumazet-laptop>
	<CAEU2+vrgxzTmiHWs-kVoKeu2_DcFZQBjCXwQfQ8dms5O6+Larg@mail.gmail.com>
	<1328222744.2480.38.camel@edumazet-laptop>
	<CAEU2+vrtwSUKgY1f44h8btcKnhvhBHUU-d_BkkyYx+E1KViQ+g@mail.gmail.com>
	<1328263278.2157.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:46802 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732Ab2BCPVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 10:21:14 -0500
Received: from mail-vw0-f46.google.com (mail-vw0-f46.google.com [209.85.212.46])
	(authenticated bits=0)
	by izzard.mines.edu (8.13.8/8.13.8) with ESMTP id q13FLDrG011816
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 3 Feb 2012 08:21:14 -0700
Received: by vbjk17 with SMTP id k17so2607513vbj.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 07:21:13 -0800 (PST)
In-Reply-To: <1328263278.2157.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2012 at 3:01 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> ...
> BTW, do we really want the htonl() thing, and force device indexes in
> 2^24 range ? This seems odd anyway.
> ...

I can easily perform both of these steps in Wine.  The 2^24 limitation
in particular seems artificial, and especially silly to add to the
kernel if it will change the fundamental range of the indices.  With
regard to htonl(), David Miller indicated that the API should match
what other systems use (a 32-bit network byte order word), though he
may not have meant his comment that specifically.  I can see the
merits of doing it both ways and I'm not particularly attached to
either one.

Erich Hoover
ehoover@mines.edu
