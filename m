From: Christoph Schulz <develop@kristov.de>
Subject: Re: [PATCH net 1/1] net: ppp: fix creating PPP pass and active
 filters
Date: Sun, 13 Jul 2014 18:07:35 +0200
Message-ID: <20140713180735.209671xd9qjsgmo7@berry.schulz.ip-v6.eu>
References: <53C28297.4080507@kristov.de> <53C29DAA.8020405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org,
	paulus@samba.org, isdn@linux-pingi.de
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server721-han.de-nserver.de ([85.158.180.102]:43274 "EHLO
	server721-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753792AbaGMQHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2014 12:07:40 -0400
In-Reply-To: <53C29DAA.8020405@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Varka Bhadram schrieb am Sun, 13 Jul 2014 20:24:34 +0530:

> checkpatch warnings on this patch

Yes, I know. But could you please give me a hint how to indent this  
properly such that it doesn't conflict with any formatting rules I  
possibly don't even know about?

+                        err = sk_unattached_filter_create(&is->pass_filter,
+                                                          &fprog);

Can I use

+                        err = sk_unattached_filter_create(
+                                &is->pass_filter, &fprog);

or similar? I do not want to rename variables to fit the line into 80  
characteres...


Regards,

Christoph Schulz
