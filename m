From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Who/What is supposed to remove IPv6 address from interface when
 moving from one network to another ?
Date: Thu, 14 Mar 2013 20:33:32 +0100
Message-ID: <CAF6-1L5cxguK8tHxjMACZJ8xNmAXLLXwP086eF4_SEctZdiZ3g@mail.gmail.com>
References: <CAF6-1L4=xACZdqvJ6AZL4XkY17N0pC9PnPfNfK9Tk7QB47c1tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: lorenzo@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:51547 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461Ab3CNTde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 15:33:34 -0400
Received: by mail-bk0-f53.google.com with SMTP id j10so1178929bkw.40
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 12:33:32 -0700 (PDT)
In-Reply-To: <CAF6-1L4=xACZdqvJ6AZL4XkY17N0pC9PnPfNfK9Tk7QB47c1tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


In a nutshell, I'm experiencing the same behavior as described here
http://kerneltrap.org/mailarchive/linux-netdev/2010/10/26/6288280 ...
but 2.5 years later ...

When switching network, my interface doesn't necessarily goes down and
so IPv6 prefixes from my old location are kept, causing issues.

I read the thread above, but it just seem to "stop" without really a
solution ...

So what's the proper thing to do ?  How is it supposed to work ?
I searched for a while and except for the thread above, I couldn't
find any reference on whose responsibility it is to cleanup. Given the
kernel added the address itself, I'd tend to agree with the original
poster and that the kernel should handle the cleanup.


Cheers,

     Sylvain
