From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [net-next (TAKE 2) 0/4] IPv6 over Firewire
Date: Sun, 10 Mar 2013 11:03:59 +0100
Message-ID: <513C5A8F.6060000@gmail.com>
References: <5117620A.4050005@linux-ipv6.org> <51177689.4070904@gmail.com> <51177B15.3030405@linux-ipv6.org> <51179714.6010706@gmail.com> <5117B73C.10600@linux-ipv6.org> <5118C8B3.7080803@gmail.com> <5118EE78.5000508@linux-ipv6.org> <511A9BFC.9010907@gmail.com> <51310507.7030904@gmail.com>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	davem@davemloft.net, stefanr@s5r6.in-berlin.de
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:50844 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732Ab3CJKED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 06:04:03 -0400
Received: by mail-ea0-f174.google.com with SMTP id q10so735837eaj.5
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 03:04:01 -0700 (PDT)
In-Reply-To: <51310507.7030904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

O.k., I rechecked all checksums send by IPv6 over FireWire from Linux
and from MacOS.

The checksums from Yoshis implementation are correct, MacOS is wrong.

What I don't understand is that using my proof of concept patch. I could
ping6 MacOSX from my Linux box. Even with CHECKSUM_UNNECESSARY MacOSX
should also throw away the packets send from Linux. Hm, I have to
recheck this.

Regards,

Stephan
