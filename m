From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH v4 1/4] Clean up indentation in net/ipv6/transp_v6.h
Date: Sun, 2 Jun 2013 19:35:53 +0900
Message-ID: <CAKD1Yr0rRBWZ8WcMSo-xoG=X8kptBdhFBk36CjLX72BZkHuSvw@mail.gmail.com>
References: <1370049940.10556.100.camel@joe-AO722> <20130601.195806.2024506377665086082.davem@davemloft.net>
 <1370142368.2086.6.camel@joe-AO722> <20130602.012918.1216932529595713857.davem@davemloft.net>
 <1370164995.2086.30.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:57311 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605Ab3FBKgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 06:36:15 -0400
Received: by mail-qc0-f169.google.com with SMTP id k15so1634064qcv.14
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 03:36:14 -0700 (PDT)
In-Reply-To: <1370164995.2086.30.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 2, 2013 at 6:23 PM, Joe Perches <joe@perches.com> wrote:
> Lorenzo, take any advice from me with whatever salts you
> think appropriate.  Avoid the designer bath ones though.

Ok, so I can:

1. Not touch any of the other functions, and add the new function
prototype without any tabs (inconsistent with the others).
2. Not touch any of the other functions, and add the new function
prototype tab-indented the same as the function above it (preserves
the status quo).
3. Remove all the externs in the function prototypes, and all the
middle-of-line tabs in the file, and add the new function prototype in
the same way.

Any of the above is fine by me. Is there one which you guys agree on?
I don't have strong feelings about indentation, but if possible I
would like to avoid re-spinning this patchset more than twice over
formatting changes to this file.
