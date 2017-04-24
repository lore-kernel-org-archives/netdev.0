From: Karim Eshapa <karim.eshapa@gmail.com>
Subject: RE:drivers:net:ethernet:adi:bfin_mac: Use FIELD_SIZEOF defined kernel macro
Date: Mon, 24 Apr 2017 02:23:10 +0200
Message-ID: <1492993390-10064-1-git-send-email-karim.eshapa@gmail.com>
References: <1492970524-12607-1-git-send-email-karim.eshapa@gmail.com>
Cc: tremyfr@gmail.com, a@unstable.cc, fw@strlen.de,
        clabbe.montjoie@gmail.com, edumazet@google.com, jarod@redhat.com,
        adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Karim Eshapa <karim.eshapa@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35263 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163687AbdDXAXV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 20:23:21 -0400
In-Reply-To: <1492970524-12607-1-git-send-email-karim.eshapa@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Apr 2017 22:56:38 +0200, Geert Uytterhoeven:
>IMHO this makes the code less safe and less future-proof.
>What if the type of info is ever changed?
>There's no safety check to validate that the FIELD_SIZEOF() operates on the
>same data as the strlcpy() destination.

Really make sense :)

>As the kbuild test robot already told you, this doesn't compile.
>Please try to (at least) compile the code before sending patches.
>Thanks!

So sorry for that I built quickly using the wrong compiler and the wrong 
target machine with my old .config that's horrible :)

Thanks a lot,
Karim
