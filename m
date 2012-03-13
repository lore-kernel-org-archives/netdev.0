From: Diego Woitasen <diego@woitasen.com.ar>
Subject: ip route show shows the routes in the inverse order?
Date: Mon, 12 Mar 2012 22:18:48 -0300
Message-ID: <CAA7Uhc=xFxiAc9ZL0KHQJ1Opr0m=Do_OuLmL7WWd7PU4JuUNnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:60227 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758275Ab2CMBSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 21:18:49 -0400
Received: by lahj13 with SMTP id j13so12496lah.19
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 18:18:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
 I've noticed that iproute and the old route command show the routes
in the inverse order. This new behavior looks related to the removal
of fib_hash (replaceed by fib_trie). I think that the old behavior
should be recovered. More specific routes in the first place looks
more natural for me and it's been the behavior for years. It doesn't
make any sense to change it.

 Sorry if this was already discussed, I couldn't find anything in the archives.

Regards,
 Diego

-- 
Diego Woitasen
