From: Oliver Mangold <o.mangold@gmail.com>
Subject: enable/disable temporary IPv6 per prefix
Date: Sun, 11 Sep 2016 09:29:16 +0200
Message-ID: <74afa986-01e5-729e-8847-2181f576893f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34950 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752511AbcIKH3S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 03:29:18 -0400
Received: by mail-wm0-f52.google.com with SMTP id a6so9110766wmc.0
        for <netdev@vger.kernel.org>; Sun, 11 Sep 2016 00:29:18 -0700 (PDT)
Received: from laptop-olli.localdomain ([2a02:8070:7b0:ed00:3458:11d3:4778:cf5a])
        by smtp.googlemail.com with ESMTPSA id o5sm11681473wmg.16.2016.09.11.00.29.16
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Sep 2016 00:29:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a question as a relatively new user to IPv6. I am wondering if it 
is currently possible to enable/disable the usage of temporary addresses 
on a per-prefix basis. My current understanding is that the feature is 
enabled by the the 'use_tempaddr' sysctl attribute, which is 
per-interface. What I would like to do is disable temp addresses for ULA 
prefixes. Did I miss something and this can already be done, or is it a 
feature planned for the future, maybe? RFC4941 seems to agree that this 
is a valid use case:


Additionally, sites might wish to selectively enable or disable the use 
of temporary addresses for some prefixes.  For example, a site might 
wish to disable temporary address generation for "Unique local" [ULA] 
prefixes while still generating temporary addresses for all other global 
prefixes.  Another site might wish to enable temporary address 
generation only for the prefixes 2001::/16 and 2002::/16, while 
disabling it for all other prefixes. To support this behavior, 
implementations SHOULD provide a way to enable and disable generation of 
temporary addresses for specific prefix subranges.  This per-prefix 
setting SHOULD override the global settings on the node with respect to 
the specified prefix subranges.  Note that the pre-prefix setting can be 
applied at any granularity, and not necessarily on a per-subnet basis.


Best regards,

Oliver
